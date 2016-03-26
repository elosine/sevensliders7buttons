SerialPort.listDevices;
(s.options.numAudioBusChannels = 300;s.waitForBoot{fork{
	var ino,cch,bh,th,ma,switchAction,toggleAction,kvalsynth;
	var samps;
	var tmpbuf = s.sendMsg(\b_allocRead,99,"/Users/jyang/GitHub/sevensliders7buttons/saxsample.aif");
	////Groups
	s.sendMsg(\g_new, 900, 1, 1);
	10.do{|ix| s.sendMsg(\g_new, 901+ix, 3, 900+ix)};
	////Samples
	s.sendMsg(\b_allocRead,0, "/Users/jyang/GitHub/sevensliders7buttons/samples/iceCreamTruckmf.aif");
	////Arduino Controlers
	ino = ArduinoSMS("/dev/tty.usbmodem1a141", 9600);
	//////Continuous Controller Headers
	cch = ["p0","p1","p2","p3","p4","p5","p6","p7"];
	//////Button Headers
	bh = ["b0","b1","b2","b3","b4","b5","b6","b7"];
	//////Toggle Headers
	th = ["bt0","bt1","bt2","bt3","bt4","bt5","bt6"];
	////////Switch Actions
	switchAction = [

	];
	////////Toggle Actions
	toggleAction = [

	];
	//////Arduino Action /////////////////////
	ino.action = {
		arg msg;
		var sm = msg.split($:);
		var header = sm[0];
		var val = sm[1].asFloat;
		//Continuous Controllers
		cch.do{ |it ix|
			if(it==header,{s.sendMsg(\n_set, 3000+ix, \val, val)} )/*end if*/};//end cch.do
		//Switches
		bh.do{ |it ix|
			if( it==sm[0], {
				var val = sm[1].asInteger;
				switchAction[ix].value(val);
			} ) //end if
		}; //end sh.do
		//Toggles
		th.do{ |it ix|
			if( it==sm[0], {
				var val = sm[1].asInteger;
				toggleAction[ix].value(val);
			} ) //end if
		}; //end sth.do
	}; //end ino.action
	//SYNTH DEFS
	/*SynthDef(\template, {
	arg ibs,obs=0,atk=0.02,rel=0.1,crv= 0,gate=1;
	var src, sig, env, amp;
	amp = \amp.kr(0.85,0.01);
	env = EnvGen.ar( Env.asr(atk, 1, rel, crv), gate );
	src = In.ar(ibs);
	sig = FX(source);
	Out.ar(obs, sig*amp*env);
	}).add;*/
	SynthDef(\kval,{
		arg obs,il=0,ih=1,ol=0,oh=1,lag=0;
		var val;
		val = \val.kr(0.0,lag).linlin(il,ih,ol,oh);
		Out.kr(obs, val);
	}).add;
	SynthDef(\playsamp, {
		arg ibs,obs=0,atk=0.02,rel=0.1,crv= 0,gate=1,buf,loop=1;
		var src, sig, env, amp;
		amp = \amp.kr(0.85,0.01);
		env = EnvGen.ar( Env.asr(atk, 1, rel, crv), gate );
		sig = PlayBuf.ar(1, buf,loop:loop);
		Out.ar(obs, sig*amp*env);
	}).add;
	SynthDef(\amplify, {
		arg ibs, obs=0, pobs, pobs2, gate=1;
		var src, sig, env, amp, sig2;
		amp = \amp.kr(0.85, 0.03);
		env = EnvGen.ar(Env.asr(releaseTime:0.01),gate,doneAction:2);
		src = In.ar(ibs);
		sig = src;
		sig2 = DelayC.ar(sig, 0.2, 0.05);
		Out.ar(pobs, [sig, sig2]*env*amp); //out to private (stereo) bus
		Out.ar(pobs2, [sig, sig2]*env*amp); //out to private (stereo) bus
		Out.ar(obs, [sig, sig2]*env*amp);
	}).add;
	SynthDef(\ampsamp, {
		arg ibs,obs=0,atk=0.02,rel=0.1,crv= 0,gate=1,buf,loop=1,
		at=0.01,rt=0.01,inamp=1;
		var src, env, amp, samp, amptrack, mx;
		amp = \amp.kr(0.85,0.01);
		src = In.ar(ibs);
		amptrack = AmplitudeMod.kr(src*inamp,at,rt).poll;
		env = EnvGen.ar( Env.asr(atk, 1, rel, crv), gate );
		samp = PlayBuf.ar(2, buf,loop:loop);
		Out.ar(obs, samp*amptrack*amp*env);
	}).add;
	SynthDef(\spectralvocoder, {
		arg ibs, obs=0, freeze = 0, mode = #[0,2,4,5,7,9,11], root=60, pchgrate=3, gate=1;
		var bufA, bufB, chain1, chain2, out, freq, amp, env;
		amp = \amp.kr(0.85, 0.05);
		env = EnvGen.ar(Env.asr(0.01, 1, 0.1),gate, doneAction:2);
		freq = (TChoose.kr(Impulse.kr(pchgrate), mode)+root).midicps;
		bufA = LocalBuf.new(2048);
		bufB = LocalBuf.new(2048);
		chain1 = FFT(bufA, LFSaw.ar( freq )); // to be filtered
		chain2 = FFT(bufB, In.ar(ibs)*10);
		chain1 = PV_SpectralMap(chain1, chain2, 0.0, freeze, 2.4, 1);
		out = IFFT(chain1);
		Out.ar(obs, out.dup*env*amp);
	}).add;
	0.1.wait;
	//SYNTHS
	////////Kval Mapping Synths
	7.do{|ix| s.sendMsg(\s_new, \kval, 3000+ix, 0, 900, \obs, ix, \il,0,\ih,1023,\ol,0.0,\oh,1.0)};
	s.sendMsg(\s_new, \playsamp, 10000, 0, 901, \obs, 100, \buf, 99, \amp, 1.5);

	//LEGEND//
	////GROUPS 900-909
	////KVAL SYNTHS 3000s
	////CONTROL BUSSES 0-6
}/*end fork*/}/*end s.waitForBoot*/)
s.sendMsg(\s_new, \ampsamp, 11000, 0, 902, \ibs, 100, \obs, 0, \buf, 0);
s.sendMsg(\n_set, 11000, \at, 0.01, \rt, 0.01, \inamp, 7, \amp, 4);
s.sendMsg(\n_free, 11000);


s.sendMsg(\s_new, \amplify, 12000, 0, 902, \ibs, 100, \obs, 0, \pobs, 150, \pobs2, 160);
s.sendMsg(\n_set, 12000, \amp, 0.5);
s.sendMsg(\n_free, 12000);