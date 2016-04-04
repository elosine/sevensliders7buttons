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
	s.sendMsg(\b_allocRead,1, "/Users/jyang/GitHub/sevensliders7buttons/Blackbird.aif");
	s.sendMsg(\b_allocRead,2, "/Users/jyang/GitHub/sevensliders7buttons/tambura.aif");
	s.sendMsg(\b_allocRead,3, "/Users/jyang/GitHub/sevensliders7buttons/unacorda.aif");
	////Arduino Controlers
	//ino = ArduinoSMS("/dev/tty.usbmodem1a141", 9600);
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
	/*
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
	*/
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
	SynthDef(\playsamp_m, {
		arg ibs,obs=0,atk=0.02,rel=0.1,crv= 0,gate=1,buf,loop=1;
		var src, sig, env, amp;
		amp = \amp.kr(0.85,0.01);
		env = EnvGen.ar( Env.asr(atk, 1, rel, crv), gate );
		sig = PlayBuf.ar(1, buf,loop:loop);
		Out.ar(obs, sig*amp*env);
	}).add;
	SynthDef(\playsamp_s, {
		arg ibs,obs=0,atk=0.02,rel=0.1,crv= 0,gate=1,buf,loop=1;
		var src, sig, env, amp;
		amp = \amp.kr(0.85,0.01);
		env = EnvGen.ar( Env.asr(atk, 1, rel, crv), gate );
		sig = PlayBuf.ar(2, buf,loop:loop);
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
		arg ibs,sibs, obs=0,atk=0.02,rel=0.1,crv= 0,gate=1,loop=1,
		at=0.01,rt=0.01,inamp=1;
		var src, env, amp, samp, amptrack, mx;
		amp = \amp.kr(0.85,0.01);
		src = In.ar(ibs);
		amptrack = AmplitudeMod.kr(src*inamp,at,rt).poll;
		env = EnvGen.ar( Env.asr(atk, 1, rel, crv), gate );
		//samp = PlayBuf.ar(2, buf,loop:loop);
		samp = In.ar(sibs, 2);
		Out.ar(obs, samp*amptrack*amp*env);
	}).add;
	SynthDef(\ringmod, {
		arg ibs1,ibs2,caramp=1, modamp=1,obs=0,atk=0.02,rel=0.1,crv= 0,gate=1;
		var car, mod1, mod2, sig1, sig2, env, amp;
		amp = \amp.kr(0.85,0.01);
		env = EnvGen.ar( Env.asr(atk, 1, rel, crv), gate );
		car = In.ar(ibs1);
		mod1 = In.ar(ibs2);
		mod2 = In.ar(ibs2+1);
		sig1 = DiodeRingMod.ar(car*caramp, mod1*modamp);
		sig2 = DiodeRingMod.ar(car*caramp, mod2*modamp);
		Out.ar(obs, [sig1,sig2]*amp*env);
	}).add;
	SynthDef(\lpc, {
		arg ibs1,ibs2,caramp=1, modamp=1,obs=0,atk=0.02,rel=0.1,crv= 0,gate=1;
		var car, mod1, mod2, sig1, sig2, env, amp;
		amp = \amp.kr(0.85,0.01);
		env = EnvGen.ar( Env.asr(atk, 1, rel, crv), gate );
		car = In.ar(ibs1);
		mod1 = In.ar(ibs2);
		mod2 = In.ar(ibs2+1);
		sig1 = LPCAnalyzer.ar(car*caramp, mod1*modamp);
		sig2 = LPCAnalyzer.ar(car*caramp, mod2*modamp);
		Out.ar(obs, [sig1,sig2]*amp*env);
	}).add;
	SynthDef(\spectralvocoder, {
		arg ibs1, ibs2, inamp1=1, inamp2=1,obs=0, freeze = 0, mode=2.4,gate=1;
		var bufA, bufB, bufC, bufD, chain1a, chain1b, chain2a, chain2b, sig1, sig2, out1, out2, freq, amp, env;
		amp = \amp.kr(0.85, 0.05);
		env = EnvGen.ar(Env.asr(0.01, 1, 0.1),gate, doneAction:2);
		bufA = LocalBuf.new(2048);
		bufB = LocalBuf.new(2048);
		bufC = LocalBuf.new(2048);
		bufD = LocalBuf.new(2048);
		chain1a = FFT(bufA, In.ar(ibs1)*inamp1); // to be filtered
		chain2a = FFT(bufB, In.ar(ibs2)*inamp2);
		sig1 = PV_SpectralMap(chain1a, chain2a, 0.0, freeze, mode, 1);
		chain1b = FFT(bufC, In.ar(ibs1)*inamp1); // to be filtered
		chain2b = FFT(bufD, In.ar(ibs2+1)*inamp2);
		sig2 = PV_SpectralMap(chain1b, chain2b, 0.0, freeze, mode, 1);
		out1 = IFFT(sig1);
		out2 = IFFT(sig2);
		Out.ar(obs, [out1,out2]*env*amp);
	}).add;
	0.1.wait;
	//SYNTHS
	////////Kval Mapping Synths
	7.do{|ix| s.sendMsg(\s_new, \kval, 3000+ix, 0, 900, \obs, ix, \il,0,\ih,1023,\ol,0.0,\oh,1.0)};
	s.sendMsg(\s_new, \playsamp_m, 10000, 0, 901, \obs, 100, \buf, 99, \amp, 1.5); //sax samp
	s.sendMsg(\s_new, \playsamp_s, 10001, 0, 902, \obs, 110, \buf, 0, \amp, 1.0); //icecream truck
	s.sendMsg(\s_new, \playsamp_s, 10002, 0, 902, \obs, 120, \buf, 1, \amp, 1.0); //blackbird
	s.sendMsg(\s_new, \playsamp_s, 10003, 0, 902, \obs, 130, \buf, 2, \amp, 1.0); //tambura
	s.sendMsg(\s_new, \playsamp_s, 10004, 0, 902, \obs, 140, \buf, 3, \amp, 1.0); //unacorda

	//LEGEND//
	////GROUPS 900-909
	////KVAL SYNTHS 3000s
	////CONTROL BUSSES 0-6
}/*end fork*/}/*end s.waitForBoot*/)
//ampsamp
s.sendMsg(\s_new, \ampsamp, 11000, 0, 903, \ibs, 100, \sibs, 110, \obs, 0);
s.sendMsg(\n_set, 11000, \at, 0.01, \rt, 0.01, \inamp, 8, \amp, 2, \sibs, 110);
s.sendMsg(\n_free, 11000);
//spectral vocoder
s.sendMsg(\s_new, \spectralvocoder, 13000, 0, 903, \ibs1, 140, \ibs2, 100);
s.sendMsg(\n_set, 13000, \inamp1, 150, \inamp2, 1, \amp, 5, \mode, 1,  \ibs1, 120, \ibs2, 100);
s.sendMsg(\n_set, 13000, \inamp1, 1, \inamp2, 100, \amp, 2, \mode, 1.1,  \ibs1, 120, \ibs2, 100);
s.sendMsg(\n_set, 13000, \inamp1, 1, \inamp2, 100, \amp, 2, \mode, 100, \ibs2, 110);
s.sendMsg(\n_free, 13000);
//ringmod
s.sendMsg(\s_new, \ringmod, 14000, 0, 903, \ibs1, 100, \ibs2, 140);
s.sendMsg(\n_set, 14000, \caramp, 2, \modamp, 5, \amp, 1, \ibs1, 100, \ibs2, 120);
s.sendMsg(\n_set, 14000, \caramp, 3, \modamp, 2, \amp, 1, \ibs1, 100, \ibs2, 130);
s.sendMsg(\n_free, 14000);
//lpc
s.sendMsg(\s_new, \lpc, 15000, 0, 903, \ibs1, 100, \ibs2, 140);
s.sendMsg(\n_set, 15000, \caramp, 1, \modamp, 1, \amp, 1, \ibs1, 100, \ibs2, 120, \amp, 0.7);
s.sendMsg(\n_set, 15000, \caramp, 3, \modamp, 2, \amp, 1, \ibs1, 100, \ibs2, 130);
s.sendMsg(\n_free, 15000);

s.sendMsg(\n_set, 10000, \obs, 0);
s.sendMsg(\n_set, 10000, \obs, 100);
s.sendMsg(\n_set, 10001, \obs, 0);
s.sendMsg(\n_set, 10001, \obs, 101);
s.sendMsg(\n_set, 10002, \obs, 0);
s.sendMsg(\n_set, 10002, \obs, 102);


s.sendMsg(\s_new, \amplify, 12000, 0, 902, \ibs, 100, \obs, 0, \pobs, 150, \pobs2, 160);
s.sendMsg(\n_set, 12000, \amp, 0.2);
s.sendMsg(\n_free, 12000);

/*
USE LPC STRICTLY
MIX WITH ONE SHOT SAMPLE PLAYBACK
////MAKE MORE LPC SAMPLES
////MAKE SOME ONE SHOT SAMPLES - FREEZE VERSIONS
*/