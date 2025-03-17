class DefenderWebEmulator {
    constructor() {
        this.canvas = document.getElementById('gameCanvas');
        this.ctx = this.canvas.getContext('2d');
        this.status = document.getElementById('status');
        this.scoreElement = document.getElementById('score');
        this.livesElement = document.getElementById('lives');
        this.startBtn = document.getElementById('startBtn');
        this.pauseBtn = document.getElementById('pauseBtn');
        
        this.isRunning = false;
        this.isPaused = false;
        this.emulator = null;
        
        this.init();
    }

    async init() {
        try {
            // Initialize JSMESS
            await this.initEmulator();
            this.setupEventListeners();
            this.status.textContent = 'Emulator ready. Click Start to begin.';
        } catch (error) {
            console.error('Failed to initialize emulator:', error);
            this.status.textContent = 'Error initializing emulator. Please refresh the page.';
        }
    }

    async initEmulator() {
        // Initialize JSMESS emulator
        // This is a placeholder - we'll need to integrate with the actual JSMESS library
        this.emulator = {
            start: () => {
                this.isRunning = true;
                this.run();
            },
            pause: () => {
                this.isPaused = !this.isPaused;
            },
            stop: () => {
                this.isRunning = false;
            }
        };
    }

    setupEventListeners() {
        // Button event listeners
        this.startBtn.addEventListener('click', () => this.startGame());
        this.pauseBtn.addEventListener('click', () => this.togglePause());

        // Keyboard event listeners
        document.addEventListener('keydown', (e) => this.handleKeyDown(e));
        document.addEventListener('keyup', (e) => this.handleKeyUp(e));

        // Touch event listeners for mobile
        this.canvas.addEventListener('touchstart', (e) => this.handleTouchStart(e));
        this.canvas.addEventListener('touchmove', (e) => this.handleTouchMove(e));
        this.canvas.addEventListener('touchend', (e) => this.handleTouchEnd(e));
    }

    startGame() {
        if (!this.isRunning) {
            this.emulator.start();
            this.startBtn.textContent = 'Restart';
            this.status.textContent = 'Game running';
        } else {
            this.restartGame();
        }
    }

    restartGame() {
        this.emulator.stop();
        this.emulator.start();
        this.score = 0;
        this.lives = 3;
        this.updateScore();
        this.updateLives();
    }

    togglePause() {
        this.emulator.pause();
        this.pauseBtn.textContent = this.isPaused ? 'Resume' : 'Pause';
        this.status.textContent = this.isPaused ? 'Game paused' : 'Game running';
    }

    handleKeyDown(event) {
        if (!this.isRunning || this.isPaused) return;

        switch(event.key) {
            case 'ArrowLeft':
                // Move left
                break;
            case 'ArrowRight':
                // Move right
                break;
            case 'ArrowUp':
                // Thrust up
                break;
            case 'ArrowDown':
                // Thrust down
                break;
            case ' ':
                // Fire
                break;
            case '1':
                // Start game
                this.startGame();
                break;
        }
    }

    handleKeyUp(event) {
        // Handle key release
    }

    handleTouchStart(event) {
        event.preventDefault();
        const touch = event.touches[0];
        this.touchStartX = touch.clientX;
        this.touchStartY = touch.clientY;
    }

    handleTouchMove(event) {
        event.preventDefault();
        if (!this.isRunning || this.isPaused) return;

        const touch = event.touches[0];
        const deltaX = touch.clientX - this.touchStartX;
        const deltaY = touch.clientY - this.touchStartY;

        // Handle touch movement
        if (Math.abs(deltaX) > 10) {
            if (deltaX > 0) {
                // Move right
            } else {
                // Move left
            }
        }

        if (Math.abs(deltaY) > 10) {
            if (deltaY > 0) {
                // Thrust down
            } else {
                // Thrust up
            }
        }
    }

    handleTouchEnd(event) {
        event.preventDefault();
        // Handle touch end
    }

    updateScore(score) {
        this.score = score;
        this.scoreElement.textContent = score.toString().padStart(6, '0');
    }

    updateLives(lives) {
        this.lives = lives;
        this.livesElement.textContent = lives;
    }

    run() {
        if (!this.isRunning || this.isPaused) return;

        // Main game loop
        // This will be implemented when we integrate with the actual emulator
        requestAnimationFrame(() => this.run());
    }
}

// Initialize the emulator when the page loads
window.addEventListener('load', () => {
    window.defenderEmulator = new DefenderWebEmulator();
}); 