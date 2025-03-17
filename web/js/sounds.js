class SoundGenerator {
    constructor() {
        this.audioContext = new (window.AudioContext || window.webkitAudioContext)();
    }

    generateSound(type) {
        const sounds = {
            shoot: {
                frequency: 880,
                duration: 0.1,
                type: 'square',
                slide: true
            },
            explosion: {
                frequency: 100,
                duration: 0.3,
                type: 'sawtooth',
                noise: true
            },
            thrust: {
                frequency: 220,
                duration: 0.2,
                type: 'square',
                noise: true,
                loop: true
            },
            smartBomb: {
                frequency: 440,
                duration: 0.4,
                type: 'sine',
                sweep: true
            },
            hyperspace: {
                frequency: 660,
                duration: 0.3,
                type: 'triangle',
                slide: true,
                reverse: true
            }
        };

        const settings = sounds[type];
        const oscillator = this.audioContext.createOscillator();
        const gainNode = this.audioContext.createGain();
        
        oscillator.type = settings.type;
        oscillator.frequency.setValueAtTime(settings.frequency, this.audioContext.currentTime);
        
        if (settings.slide) {
            oscillator.frequency.exponentialRampToValueAtTime(
                settings.reverse ? settings.frequency / 4 : settings.frequency * 2,
                this.audioContext.currentTime + settings.duration
            );
        }
        
        if (settings.sweep) {
            oscillator.frequency.exponentialRampToValueAtTime(
                settings.frequency * 3,
                this.audioContext.currentTime + settings.duration / 2
            );
            oscillator.frequency.exponentialRampToValueAtTime(
                settings.frequency / 2,
                this.audioContext.currentTime + settings.duration
            );
        }
        
        gainNode.gain.setValueAtTime(0.3, this.audioContext.currentTime);
        gainNode.gain.exponentialRampToValueAtTime(
            0.01,
            this.audioContext.currentTime + settings.duration
        );
        
        oscillator.connect(gainNode);
        gainNode.connect(this.audioContext.destination);
        
        oscillator.start();
        oscillator.stop(this.audioContext.currentTime + settings.duration);
        
        if (settings.noise) {
            const noiseBuffer = this.audioContext.createBuffer(
                1,
                this.audioContext.sampleRate * settings.duration,
                this.audioContext.sampleRate
            );
            const output = noiseBuffer.getChannelData(0);
            for (let i = 0; i < noiseBuffer.length; i++) {
                output[i] = Math.random() * 2 - 1;
            }
            
            const noiseSource = this.audioContext.createBufferSource();
            const noiseGain = this.audioContext.createGain();
            noiseGain.gain.setValueAtTime(0.1, this.audioContext.currentTime);
            
            noiseSource.buffer = noiseBuffer;
            noiseSource.connect(noiseGain);
            noiseGain.connect(this.audioContext.destination);
            
            noiseSource.start();
            if (settings.loop) {
                noiseSource.loop = true;
            }
        }
        
        return {
            stop: () => {
                oscillator.stop();
                gainNode.disconnect();
            }
        };
    }
}

// Export the sound generator
window.SoundGenerator = SoundGenerator; 