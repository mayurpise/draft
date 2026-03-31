/* ============================================================
   CANVAS — Hero perspective grid + floating particles
   ============================================================ */

(function() {
    const canvas = document.getElementById('hero-canvas');
    if (!canvas) return;

    const ctx = canvas.getContext('2d');
    let width, height, particles, animFrame;
    let lastTime = 0;
    const FPS = 30;
    const frameInterval = 1000 / FPS;

    // Particle class
    class Particle {
        constructor() {
            this.reset();
        }

        reset() {
            this.x = Math.random() * width;
            this.y = Math.random() * height;
            this.size = Math.random() * 1.5 + 0.5;
            this.speedX = (Math.random() - 0.5) * 0.3;
            this.speedY = (Math.random() - 0.5) * 0.3;
            this.opacity = Math.random() * 0.4 + 0.1;
            this.pulse = Math.random() * Math.PI * 2;
        }

        update() {
            this.x += this.speedX;
            this.y += this.speedY;
            this.pulse += 0.02;

            if (this.x < 0 || this.x > width || this.y < 0 || this.y > height) {
                this.reset();
            }
        }

        draw() {
            const alpha = this.opacity * (0.6 + 0.4 * Math.sin(this.pulse));
            ctx.beginPath();
            ctx.arc(this.x, this.y, this.size, 0, Math.PI * 2);
            ctx.fillStyle = 'rgba(34, 211, 238, ' + alpha + ')';
            ctx.fill();
        }
    }

    function resize() {
        const dpr = Math.min(window.devicePixelRatio || 1, 2);
        width = canvas.offsetWidth;
        height = canvas.offsetHeight;
        canvas.width = width * dpr;
        canvas.height = height * dpr;
        ctx.scale(dpr, dpr);
    }

    function initParticles() {
        const count = Math.min(Math.floor((width * height) / 15000), 60);
        particles = Array.from({ length: count }, () => new Particle());
    }

    function drawGrid() {
        const vanishX = width * 0.5;
        const vanishY = height * 0.4;
        const gridColor = 'rgba(34, 211, 238, 0.04)';
        const gridColorBright = 'rgba(34, 211, 238, 0.07)';

        ctx.lineWidth = 1;

        // Horizontal lines (closer together near horizon)
        const numH = 20;
        for (let i = 0; i < numH; i++) {
            const t = i / numH;
            const y = vanishY + Math.pow(t, 1.8) * (height - vanishY);
            ctx.strokeStyle = i % 4 === 0 ? gridColorBright : gridColor;
            ctx.beginPath();
            ctx.moveTo(0, y);
            ctx.lineTo(width, y);
            ctx.stroke();
        }

        // Vertical lines converging to vanishing point
        const numV = 16;
        const spread = width * 1.2;
        for (let i = -numV; i <= numV; i++) {
            const x = vanishX + (i / numV) * spread;
            ctx.strokeStyle = i % 4 === 0 ? gridColorBright : gridColor;
            ctx.beginPath();
            ctx.moveTo(vanishX, vanishY);
            ctx.lineTo(x, height);
            ctx.stroke();
        }

        // Horizon glow
        const gradient = ctx.createRadialGradient(vanishX, vanishY, 0, vanishX, vanishY, width * 0.4);
        gradient.addColorStop(0, 'rgba(34, 211, 238, 0.06)');
        gradient.addColorStop(0.5, 'rgba(167, 139, 250, 0.03)');
        gradient.addColorStop(1, 'transparent');
        ctx.fillStyle = gradient;
        ctx.fillRect(0, 0, width, height);
    }

    function animate(timestamp) {
        animFrame = requestAnimationFrame(animate);

        const delta = timestamp - lastTime;
        if (delta < frameInterval) return;
        lastTime = timestamp - (delta % frameInterval);

        ctx.clearRect(0, 0, width, height);

        drawGrid();

        for (const p of particles) {
            p.update();
            p.draw();
        }
    }

    function init() {
        resize();
        initParticles();
        animate(0);
    }

    // Debounced resize
    let resizeTimer;
    window.addEventListener('resize', function() {
        clearTimeout(resizeTimer);
        resizeTimer = setTimeout(function() {
            resize();
            initParticles();
        }, 200);
    });

    // Reduce animation when not visible
    const observer = new IntersectionObserver(function(entries) {
        if (entries[0].isIntersecting) {
            if (!animFrame) animate(0);
        } else {
            cancelAnimationFrame(animFrame);
            animFrame = null;
        }
    }, { threshold: 0.1 });

    observer.observe(canvas);

    init();
})();
