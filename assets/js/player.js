import * as Tone from "tone";

class Player{
    constructor(){}
    async setup(){
        await Tone.start();
        this.synth = new Tone.Synth().toDestination();

        this.keys =  new Tone.Players({
				urls: {
					"A": "A1.mp3",
					"B": "Cs2.mp3",
					"C": "E2.mp3",
					"D": "Fs2.mp3",
				},
				fadeOut: "64n",
				baseUrl: "https://tonejs.github.io/audio/casio/",
			}).toDestination();

            const seq = new Tone.Sequence((time, note) => {
                // this.keys.player(note).start
                this.synth.triggerAttackRelease(note, "32n");
            }, ["C2", ["Eb2", "F2", "Eb2"], "Ab2", ["Bb2", "Ab2"]]).start(0);

            // const seq2 = new Tone.Sequence((time, note) => {
            //     // this.keys.player(note).start
            //     this.synth.triggerAttackRelease(note, "8n");
            // }, ["C4", "C4", "Ab2", "Ab2"]).start(1);

            Tone.getTransport().bpm.value = 44
            Tone.getTransport().start();
    } 
    test(){
        
    }
    mute(){}
    uh_oh(){}
    hooray(){}
    pause(){
        Tone.getTransport().stop()
    }
    toggle_bass(){
        if(this.bass){
            this.bass = new Tone.Sequence((time, note) => {
                this.keys.player(note).start
            }, ["kick", "kick", "kick", "kick"]).start(0);
        }else{
            this.bass.pause()
        }
    }
    slow_down(){
        Tone.getTransport().bpm.rampTo(44,"4n")
    }
    speed_up(){
        Tone.getTransport().bpm.rampTo(60,"4n")
    }
    turn_sad(){

    }
    turn_happy(){

    }
    increment_chaos(){

    }
    resume(){}
    play_background_music(){}
    pause_background_music(){}
    
}



export default Player