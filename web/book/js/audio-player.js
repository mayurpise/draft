/**
 * DRAFT AUDIO PLAYER
 * Core logic for the integrated audiobook experience.
 * Uses Web Speech API (speechSynthesis).
 */

class DraftAudioPlayer {
    constructor() {
        this.synth = window.speechSynthesis;
        this.utterance = null;
        this.isPlaying = false;
        this.currentChapter = '';
        this.sections = [];
        this.currentIdx = -1;
        this.speed = parseFloat(localStorage.getItem('draft-audio-speed')) || 1.0;
        this.volume = parseFloat(localStorage.getItem('draft-audio-volume')) || 0.8;
        
        this.initUI();
        this.attachListeners();
    }

    initUI() {
        const playerHtml = `
            <div class="draft-audio-player" id="draft-audio-player">
                <div class="audio-player-timeline" id="audio-timeline"><div class="audio-player-progress" id="audio-progress"></div></div>
                <div class="audio-player-info">
                    <div class="audio-player-cover">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><path d="M12 1a2 2 0 0 1 2 2v10a2 2 0 0 1-4 0V3a2 2 0 0 1 2-2z"/><path d="M19 10v2a7 7 0 0 1-14 0v-2"/><line x1="12" y1="19" x2="12" y2="23"/><line x1="8" y1="23" x2="16" y2="23"/></svg>
                    </div>
                    <div class="audio-player-text">
                        <span class="audio-player-title" id="audio-title">Chapter Title</span>
                        <span class="audio-player-subtitle" id="audio-subtitle">Part I: Foundation</span>
                    </div>
                </div>
                <div class="audio-player-controls">
                    <button class="ctrl-btn" id="audio-prev" title="Previous section">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor"><path d="M6 6h2v12H6zm3.5 6L18 18V6z"/></svg>
                    </button>
                    <button class="ctrl-btn ctrl-btn-main" id="audio-play-pause">
                        <svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor" id="play-icon"><path d="M8 5v14l11-7z"/></svg>
                        <svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor" id="pause-icon" style="display:none;"><path d="M6 19h4V5H6v14zm8-14v14h4V5h-4z"/></svg>
                    </button>
                    <button class="ctrl-btn" id="audio-next" title="Next section">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor"><path d="M6 18l8.5-6L6 6v12zM16 6v12h2V6h-2z"/></svg>
                    </button>
                </div>
                <div class="audio-player-settings">
                    <span class="speed-badge" id="audio-speed-btn">${this.speed}x</span>
                    <button class="ctrl-btn" id="audio-stop" title="Stop listening">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/></svg>
                    </button>
                </div>
            </div>
        `;
        document.body.insertAdjacentHTML('beforeend', playerHtml);
        
        this.el = document.getElementById('draft-audio-player');
        this.playBtn = document.getElementById('audio-play-pause');
        this.playIcon = document.getElementById('play-icon');
        this.pauseIcon = document.getElementById('pause-icon');
        this.progressEl = document.getElementById('audio-progress');
        this.speedBtn = document.getElementById('audio-speed-btn');
        this.titleEl = document.getElementById('audio-title');
        this.subtitleEl = document.getElementById('audio-subtitle');
    }

    attachListeners() {
        this.playBtn.onclick = () => this.togglePlayback();
        document.getElementById('audio-stop').onclick = () => this.stop();
        document.getElementById('audio-prev').onclick = () => this.navigate(-1);
        document.getElementById('audio-next').onclick = () => this.navigate(1);
        this.speedBtn.onclick = () => this.cycleSpeed();
        
        // Listen for "Listen" buttons in the page
        document.addEventListener('click', (e) => {
            const btn = e.target.closest('.btn-listen-chapter');
            if (btn) {
                this.startChapterPlayback();
            }
        });

        // Global key listeners
        document.addEventListener('keydown', (e) => {
            if (this.el.classList.contains('visible')) {
                if (e.code === 'Space') {
                    e.preventDefault();
                    this.togglePlayback();
                }
            }
        });
    }

    startChapterPlayback() {
        this.stop();
        this.parseChapter();
        this.el.classList.add('visible');
        this.navigate(1);
    }

    parseChapter() {
        const wrapper = document.querySelector('.chapter-wrapper');
        const title = wrapper.querySelector('h1')?.innerText || 'The Draft Book';
        const part = document.querySelector('.part-name')?.innerText || 'Audiobook Edition';
        
        this.currentChapter = title;
        this.titleEl.innerText = title;
        this.subtitleEl.innerText = part;
        
        // Extract speakable blocks
        const blocks = Array.from(wrapper.querySelectorAll('p, h1, h2, h3, li, blockquote p'));
        this.sections = blocks.map(el => ({
            text: el.innerText.trim(),
            el: el
        })).filter(s => s.text.length > 5);
        
        this.currentIdx = -1;
    }

    navigate(dir) {
        this.currentIdx += dir;
        if (this.currentIdx < 0) this.currentIdx = 0;
        if (this.currentIdx >= this.sections.length) {
            this.stop();
            return;
        }
        
        this.speak();
    }

    speak() {
        this.synth.cancel();
        
        const section = this.sections[this.currentIdx];
        if (!section) return;

        // Visual highlight
        document.querySelectorAll('.reading-highlight').forEach(el => el.classList.remove('reading-highlight'));
        section.el.classList.add('reading-highlight');
        section.el.scrollIntoView({ behavior: 'smooth', block: 'center' });

        this.utterance = new SpeechSynthesisUtterance(section.text);
        this.utterance.rate = this.speed;
        this.utterance.volume = this.volume;
        
        // Try to find a good voice
        const voices = this.synth.getVoices();
        const preferred = voices.find(v => v.lang.startsWith('en') && (v.name.includes('Natural') || v.name.includes('Google') || v.name.includes('Apple')));
        if (preferred) this.utterance.voice = preferred;

        this.utterance.onstart = () => {
            this.isPlaying = true;
            this.updateIcons();
            this.updateProgress();
        };

        this.utterance.onend = () => {
            if (this.isPlaying) {
                this.navigate(1);
            }
        };

        this.synth.speak(this.utterance);
    }

    togglePlayback() {
        if (!this.sections.length) return;
        
        if (this.isPlaying) {
            this.synth.pause();
            this.isPlaying = false;
        } else {
            if (this.synth.paused) {
                this.synth.resume();
            } else {
                this.navigate(0); // Restart current section
            }
            this.isPlaying = true;
        }
        this.updateIcons();
    }

    stop() {
        this.synth.cancel();
        this.isPlaying = false;
        this.el.classList.remove('visible');
        document.querySelectorAll('.reading-highlight').forEach(el => el.classList.remove('reading-highlight'));
        this.updateIcons();
    }

    cycleSpeed() {
        const speeds = [1.0, 1.25, 1.5, 1.75, 2.0, 0.75];
        let idx = speeds.indexOf(this.speed);
        this.speed = speeds[(idx + 1) % speeds.length];
        this.speedBtn.innerText = `${this.speed}x`;
        localStorage.setItem('draft-audio-speed', this.speed);
        
        if (this.isPlaying) {
            this.speak(); // Restart current section with new speed
        }
    }

    updateIcons() {
        if (this.isPlaying) {
            this.playIcon.style.display = 'none';
            this.pauseIcon.style.display = 'block';
        } else {
            this.playIcon.style.display = 'block';
            this.pauseIcon.style.display = 'none';
        }
    }

    updateProgress() {
        const progress = ((this.currentIdx + 1) / this.sections.length) * 100;
        this.progressEl.style.width = `${progress}%`;
    }
}

// Initialize once scripts are loaded
window.addEventListener('DOMContentLoaded', () => {
    window.draftAudio = new DraftAudioPlayer();
});
