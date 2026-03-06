// AI Workflow Lab - GSAP Animations
document.addEventListener('DOMContentLoaded', function() {
    // Register GSAP plugins if needed
    // gsap.registerPlugin(ScrollTrigger);
    
    // Page load animations
    animatePageLoad();
    
    // Setup scroll animations
    setupScrollAnimations();
    
    // Setup filter animations
    setupFilterAnimations();
});

// Page load stagger animation
function animatePageLoad() {
    // Animate cards with stagger effect
    const cards = document.querySelectorAll('.lab-card, .ai-tool-card');
    if (cards.length > 0) {
        gsap.fromTo(cards, 
            {
                opacity: 0,
                y: 30,
                scale: 0.95
            },
            {
                opacity: 1,
                y: 0,
                scale: 1,
                duration: 0.6,
                stagger: 0.1,
                ease: "power2.out"
            }
        );
    }
    
    // Animate sidebar elements
    const sidebarElements = document.querySelectorAll('.filter-sidebar > *');
    if (sidebarElements.length > 0) {
        gsap.fromTo(sidebarElements,
            {
                opacity: 0,
                x: -20
            },
            {
                opacity: 1,
                x: 0,
                duration: 0.5,
                stagger: 0.05,
                ease: "power2.out",
                delay: 0.3
            }
        );
    }
}

// Scroll reveal animations
function setupScrollAnimations() {
    // Animate sections on scroll
    const sections = document.querySelectorAll('section');
    sections.forEach(section => {
        gsap.fromTo(section.children,
            {
                opacity: 0,
                y: 40
            },
            {
                opacity: 1,
                y: 0,
                duration: 0.8,
                stagger: 0.1,
                ease: "power2.out",
                scrollTrigger: {
                    trigger: section,
                    start: "top 80%",
                    end: "bottom 20%",
                    toggleActions: "play none none reverse"
                }
            }
        );
    });
}

// Filter change animations
function setupFilterAnimations() {
    // Observe DOM changes for filter updates
    const observer = new MutationObserver(function(mutations) {
        mutations.forEach(function(mutation) {
            if (mutation.type === 'childList') {
                // Re-animate new cards
                const newCards = document.querySelectorAll('.lab-card:not(.animated)');
                if (newCards.length > 0) {
                    gsap.fromTo(newCards,
                        {
                            opacity: 0,
                            scale: 0.9
                        },
                        {
                            opacity: 1,
                            scale: 1,
                            duration: 0.4,
                            stagger: 0.08,
                            ease: "back.out(1.7)",
                            onComplete: () => {
                                newCards.forEach(card => card.classList.add('animated'));
                            }
                        }
                    );
                }
            }
        });
    });
    
    // Start observing the main content area
    const mainContent = document.querySelector('main');
    if (mainContent) {
        observer.observe(mainContent, {
            childList: true,
            subtree: true
        });
    }
}

// Tab switching animation
function animateTabSwitch(newContent) {
    gsap.fromTo(newContent,
        {
            opacity: 0,
            y: 20
        },
        {
            opacity: 1,
            y: 0,
            duration: 0.3,
            ease: "power2.out"
        }
    );
}

// Hover effects enhancement
document.addEventListener('DOMContentLoaded', function() {
    // Enhanced card hover effects
    const cards = document.querySelectorAll('.lab-card, .ai-tool-card');
    cards.forEach(card => {
        card.addEventListener('mouseenter', function() {
            gsap.to(this, {
                scale: 1.02,
                duration: 0.2,
                ease: "power2.out"
            });
        });
        
        card.addEventListener('mouseleave', function() {
            gsap.to(this, {
                scale: 1,
                duration: 0.2,
                ease: "power2.out"
            });
        });
    });
    
    // Button hover effects
    const buttons = document.querySelectorAll('.btn-outline-success, .btn-gradient');
    buttons.forEach(button => {
        button.addEventListener('mouseenter', function() {
            gsap.to(this, {
                y: -2,
                duration: 0.15,
                ease: "power2.out"
            });
        });
        
        button.addEventListener('mouseleave', function() {
            gsap.to(this, {
                y: 0,
                duration: 0.15,
                ease: "power2.out"
            });
        });
    });
});
