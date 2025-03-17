class Game {
    constructor() {
        this.canvas = document.getElementById('game-canvas');
        this.radarCanvas = document.getElementById('radar-canvas');
        this.ctx = this.canvas.getContext('2d');
        this.radarCtx = this.radarCanvas.getContext('2d');
        
        // Main game canvas setup
        this.canvas.width = 800;
        this.canvas.height = 600;
        
        // Radar setup
        this.radarCanvas.width = 400;
        this.radarCanvas.height = 50;
        
        // Load sprites
        this.sprites = {};
        this.loadSprites();
        
        // World setup
        this.worldWidth = 3200; // Increased world width for more exploration
        this.worldOffset = 0;
        
        // Animation frames
        this.playerFrame = 0;
        this.explosionFrames = [];
        this.frameCount = 0;
        
        // Terrain setup
        this.terrain = this.generateTerrain();
        
        this.player = {
            x: 100,
            y: this.canvas.height / 2,
            width: 40,
            height: 20,
            speed: 5,
            direction: 1,
            bullets: [],
            score: 0,
            lives: 3,
            smartBombs: 3,
            thrust: 0,
            isThrusting: false
        };
        
        // Setup audio
        this.setupAudio();
        
        // Humanoids to protect
        this.humanoids = this.generateHumanoids();
        
        // Different types of enemies
        this.enemies = {
            landers: [],
            bombers: [],
            pods: [],
            swarmers: []
        };
        
        // Enemy spawn settings
        this.lastEnemySpawn = 0;
        this.enemySpawnInterval = 2000; // Spawn enemies every 2 seconds
        this.maxEnemies = {
            landers: 6,
            bombers: 3,
            pods: 2,
            swarmers: 8
        };
        
        this.keys = {
            ArrowLeft: false,
            ArrowRight: false,
            ArrowUp: false,
            ArrowDown: false,
            Space: false,
            KeyB: false, // Smart Bomb
            KeyH: false, // Hyperspace
            KeyR: false  // Reverse direction
        };
        
        this.setupEventListeners();
        this.gameLoop();
        this.spawnEnemies();
    }
    
    setupAudio() {
        this.soundGenerator = new SoundGenerator();
        this.sounds = {
            shoot: null,
            explosion: null,
            thrust: null,
            smartBomb: null,
            hyperspace: null
        };
    }
    
    loadSprites() {
        const spriteData = {
            player: [
                "    WWW     ",
                "   WWWWW    ",
                "  WWWWWWW   ",
                " WWWWWWWWW  ",
                "WWWRRRRWWWW ",
                "WWRRRRRRRWW ",
                "WWWRRRRWWWW ",
                " WWWWWWWWW  ",
                "  WWWWWWW   ",
                "   WWWWW    ",
                "    WWW     "
            ],
            lander: [
                "  YYYY  ",
                " YYWWYY ",
                "YYWWWWYY",
                "YYYWWYYY",
                "YYYWWYYY",
                "YYWWWWYY",
                " YYWWYY ",
                "  YYYY  "
            ],
            bomber: [
                "   MM   ",
                "  MMMM  ",
                " MMMMMM ",
                "MMWWWWMM",
                "MMWWWWMM",
                " MMMMMM ",
                "  MMMM  ",
                "   MM   "
            ],
            pod: [
                " RRRR ",
                "RRRRRR",
                "RWWWWR",
                "RWWWWR",
                "RRRRRR",
                " RRRR "
            ],
            swarmer: [
                " RR ",
                "RRRR",
                "RRRR",
                " RR "
            ],
            explosion: [
                "    RRR    ",
                "   RRRRR   ",
                "  RRYYYRR  ",
                " RRYYYYYYR ",
                "RRYYYWYYYRR",
                "RRYYYYYYRR ",
                " RRYYYRR  ",
                "  RRRRR   ",
                "   RRR    "
            ]
        };

        // Convert ASCII art to canvas patterns
        for (let [name, art] of Object.entries(spriteData)) {
            const canvas = document.createElement('canvas');
            const size = art[0].length;
            canvas.width = size * 2;
            canvas.height = art.length * 2;
            const ctx = canvas.getContext('2d');
            
            for (let y = 0; y < art.length; y++) {
                for (let x = 0; x < size; x++) {
                    const color = {
                        'G': '#0f0',   // Green
                        'W': '#fff',   // White
                        'R': '#f00',   // Red
                        'Y': '#ff0',   // Yellow
                        'M': '#f0f',   // Magenta
                        ' ': 'transparent'
                    }[art[y][x]];
                    
                    if (color !== 'transparent') {
                        ctx.fillStyle = color;
                        ctx.fillRect(x * 2, y * 2, 2, 2);
                    }
                }
            }
            this.sprites[name] = canvas;
        }
    }
    
    generateTerrain() {
        const points = [];
        let x = 0;
        let y = this.canvas.height - 100;
        
        // Generate initial terrain
        while (x < this.worldWidth) {
            points.push({x, y});
            x += 25;
            // Add some initial variation
            y += (Math.random() - 0.5) * 20;
            y = Math.max(this.canvas.height - 200, Math.min(this.canvas.height - 50, y));
        }
        return points;
    }
    
    generateHumanoids() {
        const humanoids = [];
        for (let i = 0; i < 10; i++) {
            humanoids.push({
                x: Math.random() * this.worldWidth,
                y: this.canvas.height - 40,
                width: 10,
                height: 20,
                isBeingAbducted: false
            });
        }
        return humanoids;
    }
    
    setupEventListeners() {
        document.addEventListener('keydown', (e) => {
            if (e.code in this.keys) {
                this.keys[e.code] = true;
                if (e.code === 'Space') {
                    this.shoot();
                } else if (e.code === 'KeyB') {
                    this.useSmartBomb();
                } else if (e.code === 'KeyH') {
                    this.hyperspace();
                } else if (e.code === 'KeyR') {
                    // Flip player direction and adjust position for smooth transition
                    const centerX = this.player.x + this.player.width / 2;
                    this.player.direction *= -1;
                    this.player.x = centerX - this.player.width / 2;
                }
            }
        });
        
        document.addEventListener('keyup', (e) => {
            if (e.code in this.keys) {
                this.keys[e.code] = false;
            }
        });
    }
    
    shoot() {
        const bulletSpeed = 10 * this.player.direction;
        const bulletWidth = 10;
        
        // Calculate bullet starting position based on player direction
        const bulletX = this.player.direction > 0 
            ? this.player.x + this.player.width 
            : this.player.x - bulletWidth;
            
        this.player.bullets.push({
            x: bulletX,
            y: this.player.y + this.player.height / 2 - 1,
            speed: bulletSpeed,
            width: bulletWidth,
            height: 2,
            direction: this.player.direction
        });
        
        this.soundGenerator.generateSound('shoot');
    }
    
    useSmartBomb() {
        if (this.player.smartBombs > 0) {
            this.player.smartBombs--;
            this.soundGenerator.generateSound('smartBomb');
            
            // Create multiple explosion effects
            for (let i = 0; i < 10; i++) {
                setTimeout(() => {
                    const x = Math.random() * this.canvas.width;
                    const y = Math.random() * this.canvas.height;
                    this.createExplosion(x, y, true);
                }, i * 100);
            }
            
            // Clear all visible enemies
            Object.keys(this.enemies).forEach(type => {
                this.enemies[type] = this.enemies[type].filter(enemy => {
                    const isVisible = enemy.x >= this.worldOffset - 100 && 
                                    enemy.x <= this.worldOffset + this.canvas.width + 100;
                    if (isVisible) {
                        // Create explosion at enemy position
                        this.createExplosion(enemy.x, enemy.y);
                        // Free any abducted humanoids
                        if (type === 'lander' && enemy.isAbducting) {
                            enemy.targetHumanoid.isBeingAbducted = false;
                            enemy.targetHumanoid.y = this.canvas.height - 40;
                        }
                    }
                    return !isVisible;
                });
            });
            
            document.getElementById('smart-bombs').textContent = `Smart Bombs: ${this.player.smartBombs}`;
        }
    }
    
    hyperspace() {
        this.soundGenerator.generateSound('hyperspace');
        this.player.x = Math.random() * (this.canvas.width - this.player.width);
        this.player.y = Math.random() * (this.canvas.height - this.player.height);
    }
    
    spawnEnemies() {
        const now = Date.now();
        if (now - this.lastEnemySpawn > this.enemySpawnInterval) {
            // Spawn enemies on both sides of the screen
            const spawnSide = Math.random() < 0.5;
            const spawnX = spawnSide ? 
                this.worldOffset + this.canvas.width + 50 : 
                this.worldOffset - 50;
            const spawnY = Math.random() * (this.canvas.height - 100);
            
            // Lander - Basic enemy that tries to capture humanoids
            if (Object.keys(this.enemies.landers).length < this.maxEnemies.landers && Math.random() < 0.4) {
                this.enemies.landers.push({
                    x: spawnX,
                    y: spawnY,
                    width: 35,
                    height: 35,
                    speed: 3,
                    type: 'lander',
                    targetHumanoid: null,
                    direction: spawnSide ? -1 : 1
                });
            }
            
            // Bomber - Drops mines and moves in a wave pattern
            if (Object.keys(this.enemies.bombers).length < this.maxEnemies.bombers && Math.random() < 0.3) {
                this.enemies.bombers.push({
                    x: spawnX,
                    y: spawnY,
                    width: 40,
                    height: 40,
                    speed: 4,
                    type: 'bomber',
                    waveOffset: Math.random() * Math.PI * 2,
                    direction: spawnSide ? -1 : 1
                });
            }
            
            // Pod - Releases swarmers when destroyed
            if (Object.keys(this.enemies.pods).length < this.maxEnemies.pods && Math.random() < 0.2) {
                this.enemies.pods.push({
                    x: spawnX,
                    y: spawnY,
                    width: 30,
                    height: 30,
                    speed: 2,
                    type: 'pod',
                    health: 2,
                    direction: spawnSide ? -1 : 1
                });
            }
            
            this.lastEnemySpawn = now;
        }
    }
    
    generateTerrainSegment(startX, startY) {
        const points = [];
        let x = startX;
        let y = startY;
        const segmentWidth = 400; // Generate terrain in chunks
        
        while (x < startX + segmentWidth) {
            // Add some randomization to the terrain
            y += (Math.random() - 0.5) * 20;
            // Keep terrain within bounds
            y = Math.max(this.canvas.height - 200, Math.min(this.canvas.height - 50, y));
            points.push({x, y});
            x += 25; // Smaller segments for more detail
        }
        return points;
    }

    updateTerrain() {
        // Remove terrain points that are far behind
        this.terrain = this.terrain.filter(point => 
            point.x >= this.worldOffset - 400
        );

        // Add new terrain points ahead
        const lastPoint = this.terrain[this.terrain.length - 1];
        if (lastPoint.x < this.worldOffset + this.canvas.width + 400) {
            const newSegment = this.generateTerrainSegment(
                lastPoint.x,
                lastPoint.y
            );
            this.terrain.push(...newSegment);
        }
    }

    update() {
        this.frameCount++;
        
        // Update player thrust state and sounds
        const isThrusting = this.keys.ArrowUp || this.keys.ArrowDown;
        if (isThrusting) {
            if (!this.sounds.thrust) {
                this.sounds.thrust = this.soundGenerator.generateSound('thrust');
            }
            this.player.isThrusting = true;
        } else {
            if (this.sounds.thrust) {
                this.sounds.thrust.stop();
                this.sounds.thrust = null;
            }
            this.player.isThrusting = false;
        }
        
        // Update enemies
        this.updateEnemies();
        
        // Update player animation
        if (this.frameCount % 6 === 0) {
            this.playerFrame = (this.playerFrame + 1) % 2;
        }
        
        // Update player position
        if (this.keys.ArrowLeft) this.player.x -= this.player.speed;
        if (this.keys.ArrowRight) this.player.x += this.player.speed;
        if (this.keys.ArrowUp) this.player.y -= this.player.speed;
        if (this.keys.ArrowDown) this.player.y += this.player.speed;
        
        // Continuous scrolling in both directions
        if (this.player.x > this.canvas.width * 0.7) {
            this.worldOffset += this.player.speed;
            this.player.x -= this.player.speed;
            // Wrap around to the beginning if we reach the end
            if (this.worldOffset >= this.worldWidth) {
                this.worldOffset = 0;
            }
            this.updateTerrain();
        } else if (this.player.x < this.canvas.width * 0.3) {
            this.worldOffset -= this.player.speed;
            this.player.x += this.player.speed;
            // Wrap around to the end if we reach the beginning
            if (this.worldOffset < 0) {
                this.worldOffset = this.worldWidth - this.canvas.width;
            }
            this.updateTerrain();
        }
        
        // Keep player in vertical bounds only
        this.player.y = Math.max(0, Math.min(this.canvas.height - this.player.height, this.player.y));
        
        // Update bullets with wrapping
        this.player.bullets = this.player.bullets.filter(bullet => {
            bullet.x += bullet.speed;
            // Wrap bullets around the world
            if (bullet.x > this.canvas.width) {
                bullet.x = 0;
            } else if (bullet.x < 0) {
                bullet.x = this.canvas.width;
            }
            // Keep bullets for a certain distance
            bullet.distance = (bullet.distance || 0) + Math.abs(bullet.speed);
            return bullet.distance < this.canvas.width * 2;
        });
        
        // Check collisions
        this.checkCollisions();
        
        // Spawn new enemies
        this.spawnEnemies();
    }
    
    updateEnemies() {
        // Update Landers
        this.enemies.landers.forEach(lander => {
            if (!lander.targetHumanoid) {
                // Find closest humanoid that isn't being abducted
                const availableHumanoids = this.humanoids.filter(h => !h.isBeingAbducted);
                if (availableHumanoids.length > 0) {
                    lander.targetHumanoid = availableHumanoids.reduce((closest, humanoid) => {
                        const distToCurrent = Math.hypot(
                            lander.x - humanoid.x,
                            lander.y - humanoid.y
                        );
                        const distToClosest = closest ? Math.hypot(
                            lander.x - closest.x,
                            lander.y - closest.y
                        ) : Infinity;
                        return distToCurrent < distToClosest ? humanoid : closest;
                    }, null);
                }
            }
            
            if (lander.targetHumanoid) {
                // Move towards target humanoid more aggressively
                const targetX = lander.targetHumanoid.x;
                const targetY = lander.targetHumanoid.y - 50;
                const dx = targetX - lander.x;
                const dy = targetY - lander.y;
                const dist = Math.hypot(dx, dy);
                
                if (dist < 5) {
                    lander.targetHumanoid.isBeingAbducted = true;
                    lander.isAbducting = true;
                    lander.y -= 1.5; // Faster abduction
                    lander.targetHumanoid.y = lander.y + 50;
                    
                    if (lander.y < -50) {
                        this.humanoids = this.humanoids.filter(h => h !== lander.targetHumanoid);
                        lander.targetHumanoid = null;
                        lander.isAbducting = false;
                    }
                } else {
                    const speed = lander.speed * 1.5; // More aggressive pursuit
                    lander.x += (dx / dist) * speed;
                    lander.y += (dy / dist) * speed;
                }
            } else {
                // More aggressive patrol pattern
                lander.x += Math.cos(this.frameCount * 0.03) * lander.speed * 1.2;
                lander.y += Math.sin(this.frameCount * 0.06) * lander.speed * 1.2;
            }
            
            // Keep lander in bounds and wrap around horizontally
            if (lander.x > this.canvas.width + 50) {
                lander.x = -50;
            } else if (lander.x < -50) {
                lander.x = this.canvas.width + 50;
            }
            lander.y = Math.max(50, Math.min(this.canvas.height - 100, lander.y));
        });
        
        // Update Bombers with more aggressive movement
        this.enemies.bombers.forEach(bomber => {
            bomber.x += bomber.speed * bomber.direction;
            bomber.y += Math.sin((this.frameCount * 0.05) + bomber.waveOffset) * 3;
            
            // Wrap bombers around the screen
            if (bomber.x > this.canvas.width + 50) {
                bomber.x = -50;
            } else if (bomber.x < -50) {
                bomber.x = this.canvas.width + 50;
            }
        });
        
        // Update Pods with wrapping
        this.enemies.pods.forEach(pod => {
            pod.x += pod.speed * pod.direction;
            pod.y += Math.sin(this.frameCount * 0.02) * 0.8;
            
            if (pod.x > this.canvas.width + 50) {
                pod.x = -50;
            } else if (pod.x < -50) {
                pod.x = this.canvas.width + 50;
            }
        });
        
        // Update Swarmers with more aggressive behavior
        this.enemies.swarmers.forEach(swarmer => {
            // Target player more aggressively
            const dx = this.player.x - swarmer.x;
            const dy = this.player.y - swarmer.y;
            const dist = Math.hypot(dx, dy);
            
            if (dist < 200) { // If close to player, chase more aggressively
                swarmer.angle = Math.atan2(dy, dx) + (Math.random() - 0.5) * 0.5;
            } else {
                swarmer.angle += (Math.random() - 0.5) * 0.3;
            }
            
            swarmer.x += Math.cos(swarmer.angle) * swarmer.speed;
            swarmer.y += Math.sin(swarmer.angle) * swarmer.speed;
            
            // Wrap swarmers around the screen
            if (swarmer.x > this.canvas.width + 20) {
                swarmer.x = -20;
            } else if (swarmer.x < -20) {
                swarmer.x = this.canvas.width + 20;
            }
            if (swarmer.y < 0 || swarmer.y > this.canvas.height) {
                swarmer.angle = -swarmer.angle;
            }
        });
        
        // Remove enemies that are off screen
        Object.keys(this.enemies).forEach(type => {
            this.enemies[type] = this.enemies[type].filter(enemy => 
                enemy.x > -enemy.width && 
                enemy.x < this.canvas.width + enemy.width &&
                enemy.y > -enemy.height &&
                enemy.y < this.canvas.height + enemy.height
            );
        });
    }
    
    checkCollision(rect1, rect2) {
        return rect1.x < rect2.x + rect2.width &&
               rect1.x + rect1.width > rect2.x &&
               rect1.y < rect2.y + rect2.height &&
               rect1.y + rect1.height > rect2.y;
    }
    
    checkCollisions() {
        // Check bullet collisions with enemies
        this.player.bullets.forEach((bullet, bulletIndex) => {
            Object.keys(this.enemies).forEach(type => {
                this.enemies[type].forEach((enemy, enemyIndex) => {
                    if (this.checkCollision(bullet, enemy)) {
                        // Remove the bullet
                        this.player.bullets.splice(bulletIndex, 1);
                        
                        if (type === 'pod') {
                            enemy.health--;
                            if (enemy.health <= 0) {
                                this.enemies[type].splice(enemyIndex, 1);
                                this.handlePodDestruction(enemy);
                                this.score += 1000;
                            }
                        } else {
                            // If it's a lander and it was abducting, free the humanoid
                            if (type === 'lander' && enemy.isAbducting) {
                                enemy.targetHumanoid.isBeingAbducted = false;
                                enemy.targetHumanoid.y = this.canvas.height - 40;
                            }
                            
                            // Remove the enemy
                            this.enemies[type].splice(enemyIndex, 1);
                            this.score += type === 'swarmer' ? 150 : 100;
                        }
                        
                        document.getElementById('score').textContent = `Score: ${this.score}`;
                        this.soundGenerator.generateSound('explosion');
                        this.createExplosion(enemy.x + enemy.width / 2, enemy.y + enemy.height / 2);
                    }
                });
            });
        });

        // Check player collision with enemies
        Object.keys(this.enemies).forEach(type => {
            this.enemies[type].forEach((enemy, index) => {
                if (this.checkCollision(this.player, enemy)) {
                    this.soundGenerator.generateSound('explosion');
                    this.createExplosion(this.player.x + this.player.width / 2, this.player.y + this.player.height / 2);
                    this.player.lives--;
                    document.getElementById('lives').textContent = `Ships: ${this.player.lives}`;
                    if (this.player.lives <= 0) {
                        alert('Game Over! Refresh to restart.');
                        this.gameOver = true;
                    }
                }
            });
        });
    }
    
    drawTerrain(ctx, isRadar = false) {
        ctx.beginPath();
        ctx.moveTo(0, this.canvas.height);
        
        this.terrain.forEach((point, i) => {
            if (i === 0) {
                ctx.moveTo(point.x - this.worldOffset, point.y);
            } else {
                ctx.lineTo(point.x - this.worldOffset, point.y);
            }
        });
        
        ctx.strokeStyle = '#0f0';
        ctx.lineWidth = isRadar ? 1 : 2;
        ctx.stroke();
    }
    
    draw() {
        // Clear main canvas
        this.ctx.fillStyle = '#000';
        this.ctx.fillRect(0, 0, this.canvas.width, this.canvas.height);
        
        // Draw terrain with glow effect
        this.ctx.beginPath();
        this.ctx.strokeStyle = '#0f0';
        this.ctx.lineWidth = 2;
        this.ctx.shadowBlur = 5;
        this.ctx.shadowColor = '#0f0';
        
        // Draw terrain
        this.terrain.forEach((point, i) => {
            if (i === 0) {
                this.ctx.moveTo(point.x - this.worldOffset, point.y);
            } else {
                this.ctx.lineTo(point.x - this.worldOffset, point.y);
            }
        });
        
        this.ctx.stroke();
        this.ctx.shadowBlur = 0;
        
        // Draw player with proper direction
        this.ctx.save();
        this.ctx.translate(
            this.player.x + this.player.width / 2,
            this.player.y + this.player.height / 2
        );
        this.ctx.scale(this.player.direction, 1);
        this.ctx.drawImage(
            this.sprites.player,
            -this.player.width / 2,
            -this.player.height / 2,
            this.player.width,
            this.player.height
        );
        
        // Draw thrust effect
        if (this.player.isThrusting) {
            this.ctx.fillStyle = this.playerFrame ? '#f00' : '#ff0';
            this.ctx.fillRect(
                -this.player.width / 2 - 10,
                -5,
                8,
                10
            );
        }
        this.ctx.restore();
        
        // Draw bullets with glow effect
        this.ctx.shadowBlur = 10;
        this.ctx.shadowColor = '#f00';
        this.ctx.fillStyle = '#f00';
        this.player.bullets.forEach(bullet => {
            this.ctx.fillRect(bullet.x, bullet.y, bullet.width * bullet.direction, bullet.height);
        });
        this.ctx.shadowBlur = 0;
        
        // Draw enemies with sprites
        Object.keys(this.enemies).forEach(type => {
            const sprite = this.sprites[type];
            if (sprite) {
                this.enemies[type].forEach(enemy => {
                    this.ctx.drawImage(sprite, enemy.x, enemy.y, enemy.width, enemy.height);
                });
            }
        });
        
        // Draw humanoids with abduction beam effect
        this.ctx.fillStyle = '#0ff';
        this.humanoids.forEach(humanoid => {
            const bobOffset = Math.sin(this.frameCount * 0.1) * 2;
            this.ctx.fillRect(
                humanoid.x - this.worldOffset,
                humanoid.y + bobOffset,
                humanoid.width,
                humanoid.height
            );
            
            // Draw abduction beam
            if (humanoid.isBeingAbducted) {
                this.ctx.save();
                this.ctx.strokeStyle = '#ff0';
                this.ctx.lineWidth = 1;
                this.ctx.setLineDash([5, 5]);
                this.ctx.beginPath();
                this.ctx.moveTo(humanoid.x - this.worldOffset + humanoid.width / 2, humanoid.y);
                this.ctx.lineTo(humanoid.x - this.worldOffset + humanoid.width / 2, humanoid.y - 50);
                this.ctx.stroke();
                this.ctx.setLineDash([]);
                this.ctx.restore();
            }
        });
        
        // Draw explosions with glow effects
        this.drawExplosions();
        
        // Update radar
        this.drawRadar();
    }
    
    drawRadar() {
        // Clear radar canvas
        this.radarCtx.fillStyle = '#000';
        this.radarCtx.fillRect(0, 0, this.radarCanvas.width, this.radarCanvas.height);
        
        // Draw radar border
        this.radarCtx.strokeStyle = '#0f0';
        this.radarCtx.strokeRect(0, 0, this.radarCanvas.width, this.radarCanvas.height);
        
        // Calculate scale for radar
        const scale = this.radarCanvas.width / this.worldWidth;
        
        // Draw player position on radar
        const radarPlayerX = (this.player.x + this.worldOffset) * scale;
        this.radarCtx.fillStyle = '#0f0';
        this.radarCtx.fillRect(radarPlayerX, this.radarCanvas.height / 2, 2, 2);
        
        // Draw enemies on radar
        this.radarCtx.fillStyle = '#ff0';
        Object.keys(this.enemies).forEach(type => {
            this.enemies[type].forEach(enemy => {
                const radarX = enemy.x * scale;
                this.radarCtx.fillRect(radarX, this.radarCanvas.height / 2, 1, 1);
            });
        });
        
        // Draw humanoids on radar
        this.radarCtx.fillStyle = '#0ff';
        this.humanoids.forEach(humanoid => {
            const radarX = humanoid.x * scale;
            this.radarCtx.fillRect(radarX, this.radarCanvas.height * 0.8, 1, 1);
        });
    }
    
    gameLoop() {
        this.update();
        this.draw();
        requestAnimationFrame(() => this.gameLoop());
    }

    // Add pod destruction handler
    handlePodDestruction(pod) {
        // Spawn 3-4 swarmers when a pod is destroyed
        const numSwarmers = 3 + Math.floor(Math.random() * 2);
        for (let i = 0; i < numSwarmers; i++) {
            this.enemies.swarmers.push({
                x: pod.x,
                y: pod.y,
                width: 20,
                height: 20,
                speed: 4,
                type: 'swarmer',
                angle: (Math.PI * 2 * i) / numSwarmers
            });
        }
    }

    createExplosion(x, y, isLarge = false) {
        const size = isLarge ? 2 : 1;
        const particles = [];
        const numParticles = isLarge ? 20 : 10;
        
        for (let i = 0; i < numParticles; i++) {
            const angle = (Math.PI * 2 * i) / numParticles;
            const speed = 2 + Math.random() * 2;
            particles.push({
                x,
                y,
                vx: Math.cos(angle) * speed,
                vy: Math.sin(angle) * speed,
                life: 1.0,
                size: (isLarge ? 4 : 2) * size,
                color: isLarge ? 
                    ['#ff0', '#f00', '#f80'][Math.floor(Math.random() * 3)] :
                    ['#f00', '#ff0'][Math.floor(Math.random() * 2)]
            });
        }
        
        this.explosionFrames.push({
            particles,
            isLarge
        });
    }

    drawExplosions() {
        this.explosionFrames = this.explosionFrames.filter(explosion => {
            explosion.particles = explosion.particles.filter(particle => {
                // Update particle position
                particle.x += particle.vx;
                particle.y += particle.vy;
                particle.life -= 0.02;
                
                if (particle.life > 0) {
                    // Draw particle with glow effect
                    this.ctx.save();
                    this.ctx.globalAlpha = particle.life;
                    this.ctx.shadowBlur = 10;
                    this.ctx.shadowColor = particle.color;
                    this.ctx.fillStyle = particle.color;
                    this.ctx.beginPath();
                    this.ctx.arc(particle.x, particle.y, particle.size, 0, Math.PI * 2);
                    this.ctx.fill();
                    this.ctx.restore();
                    return true;
                }
                return false;
            });
            return explosion.particles.length > 0;
        });
    }
}

// Start the game when the page loads
window.onload = () => new Game(); 