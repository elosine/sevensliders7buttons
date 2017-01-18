#define NP 7
#define NB 7
#define NFSR 0

//pot
//int np = 7; //number of pots
int p[NP] = { A3, A2,A1,A0,A8,A9,A10 }; //analog input pins
int pv[NP];//pot value
int ppv[NP] = {0, 0,0,0,0,0,0}; //previous pot value

//buttons
//int nb = 7;
int b[] = { 2, 3,4,5,6,7,16 }; //digital input pins
boolean bg[] = {true, true, true, true, true, true, true};//momentary button gates
////button toggle
int btv[] = { 0, 0,0,0,0,0,0 }; //toggle button current value
int btamt[] = { 10,2,2,2,2,2,2 }; //number of toggles
boolean btg[] = {true, true, true, true, true, true, true};//toggle button gates

//fsrs
//int numsens = 0;
int fsr[] = {A5};
int val[1];
int thresh[] = {100};
boolean peakgate[] = {true};
int pval[] = {0};

void setup() {
  Serial.begin(9600);
  //sets the digital pins for the buttons to input and pulls resistor high
  for (int i = 0; i < NB; i++) {
    pinMode(b[i], INPUT_PULLUP);
  } //end for (int i = 0; i < NB; i++) loop thru all buttons
} //end setup


void loop() {
  //FSRs
  for (int i = 0; i < NFSR; i++) {
    val[i] = analogRead(fsr[i]);
    //Peak Detection
    if (val[i] > thresh[i]) {
      Serial.print("fsr");
      Serial.print(i);
      Serial.print(":");
      Serial.println(val[i]);
      if (val[i] > pval[i]) { //is it going up?
        pval[i] = val[i];
      }
      else { //its going down i.e., val<pval
        if (peakgate[i]) { //if gate is open
          Serial.print("fsp");
          Serial.print(i);
          Serial.print(":");
          Serial.println(pval[i]); //this is our peak
          peakgate[i] = false; //close gate
        }
      }
    }
    else { //is below thresh
      peakgate[i] = true;
      pval[i] = 0;
    }
  }

  //POTS
  for (int i = 0; i < NP; i++) { //loop thru all pots
    pv[i] = analogRead(p[i]); //read analog pin
    //Send out values only when pot changes
    if ( pv[i] < (ppv[i] - 2) || pv[i] > (ppv[i] + 2) ) {
      //Action
      Serial.print( "p" + String(i) + ":");
      Serial.println(pv[i]); //send value to serial bus
    }
    //Update previous value
    ppv[i] = pv[i];


  }//end loop thru all pots


  //BUTTONS

  for (int i = 0; i < NB; i++) { //loop thru all buttons

    //if button is pressed (reads LOW)
    if ( digitalRead(b[i]) == LOW ) { //button on

      ////Momentary
      if (bg[i]) {
        bg[i] = false;
        Serial.print( "b" + String(i) + ":");
        Serial.println(1);
      }

      ////Toggles
      if (btg[i]) {
        btg[i] = false; //CLOSE GATE
        btv[i] = btv[i] + 1; //INC VALUE
        btv[i] = btv[i] % btamt[i]; //MOD VALUE
        Serial.print( "bt" + String(i) + ":"); //PRINT HEADER
        Serial.println(btv[i]); //PRINT VAL
      }

    } //end if button pressed

    //if button is released (reads HIGH)
    if ( digitalRead(b[i]) == HIGH ) { //button off

      ////Momentary
      if (!bg[i]) {
        bg[i] = true;
        Serial.print( "b" + String(i) + ":");
        Serial.println(0);
      }

      ////Toggles
      if (!btg[i]) {
        btg[i] = true;
      }

    } //end if button released


  } //end loop all buttons
  delay(15);

} //end void loop


