import * as Tone from "tone";
// const synth = new Tone.Synth().toDestination();
// synth.triggerAttackRelease(`C${Number.parseInt(image_id)+3}`, "8n");

class Player{
    constructor(){}
    async setup(){
        await Tone.start();
        this.synth = new Tone.Synth().toDestination();

        this.keys =  new Tone.Players({
				urls: {
					0: "A1.mp3",
					1: "Cs2.mp3",
					2: "E2.mp3",
					3: "Fs2.mp3",
				},
				fadeOut: "64n",
				baseUrl: "https://tonejs.github.io/audio/casio/",
			}).toDestination();
    } 
    test(){
        const seq = new Tone.Sequence((time, note) => {
            // this.synth.triggerAttackRelease(note, 0.1, time);
            this.keys.player(note).start
        }, [0, [1, 2, 1], 2, [3, 4]]).start(0);
        // Tone.getTransport().bpm.value = 80
        Tone.getTransport().start();
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

    }
    speed_up(){

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