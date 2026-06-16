// Duniya Documentation — Custom JavaScript
// Lightweight enhancements for a world-class reading experience.

(function () {
  'use strict';

  // Smooth-scroll to anchor links (with offset for the sticky header).
  document.addEventListener('DOMContentLoaded', function () {
    var links = document.querySelectorAll('a[href^="#"]');
    links.forEach(function (link) {
      link.addEventListener('click', function (e) {
        var targetId = link.getAttribute('href');
        if (targetId === '#' || targetId.length < 2) return;
        var target = document.querySelector(targetId);
        if (!target) return;
        e.preventDefault();
        var headerHeight = 80;
        var targetPosition = target.getBoundingClientRect().top + window.pageYOffset - headerHeight;
        window.scrollTo({ top: targetPosition, behavior: 'smooth' });
      });
    });
  });

  // Add a "Back to top" button that appears on scroll.
  document.addEventListener('DOMContentLoaded', function () {
    var button = document.createElement('button');
    button.innerHTML = '&uarr;';
    button.setAttribute('aria-label', 'Back to top');
    button.style.cssText = [
      'position: fixed',
      'bottom: 24px',
      'right: 24px',
      'width: 44px',
      'height: 44px',
      'border-radius: 50%',
      'border: none',
      'background: linear-gradient(135deg, #9900ff, #6a00d9)',
      'color: white',
      'font-size: 18px',
      'cursor: pointer',
      'opacity: 0',
      'visibility: hidden',
      'transition: opacity 0.3s ease, visibility 0.3s ease, transform 0.2s ease',
      'box-shadow: 0 4px 16px rgba(106, 0, 217, 0.3)',
      'z-index: 1000'
    ].join(';');
    document.body.appendChild(button);

    window.addEventListener('scroll', function () {
      if (window.pageYOffset > 400) {
        button.style.opacity = '1';
        button.style.visibility = 'visible';
      } else {
        button.style.opacity = '0';
        button.style.visibility = 'hidden';
      }
    });

    button.addEventListener('click', function () {
      window.scrollTo({ top: 0, behavior: 'smooth' });
    });

    button.addEventListener('mouseenter', function () {
      button.style.transform = 'translateY(-3px) scale(1.05)';
    });
    button.addEventListener('mouseleave', function () {
      button.style.transform = 'translateY(0) scale(1)';
    });
  });

  // Open external links in a new tab.
  document.addEventListener('DOMContentLoaded', function () {
    var links = document.querySelectorAll('a[href^="http"]');
    links.forEach(function (link) {
      var href = link.getAttribute('href');
      if (href && href.indexOf(window.location.hostname) === -1) {
        link.setAttribute('target', '_blank');
        link.setAttribute('rel', 'noopener noreferrer');
      }
    });
  });

  // Add a "Reading progress" bar at the top of the page.
  document.addEventListener('DOMContentLoaded', function () {
    var progressBar = document.createElement('div');
    progressBar.style.cssText = [
      'position: fixed',
      'top: 0',
      'left: 0',
      'height: 3px',
      'width: 0%',
      'background: linear-gradient(90deg, #9900ff, #6a00d9)',
      'z-index: 9999',
      'transition: width 0.1s ease'
    ].join(';');
    document.body.appendChild(progressBar);

    window.addEventListener('scroll', function () {
      var scrollHeight = document.documentElement.scrollHeight - window.innerHeight;
      var scrolled = (window.pageYOffset / scrollHeight) * 100;
      progressBar.style.width = scrolled + '%';
    });
  });

  // Animate the "hero-grid" cards on load (subtle fade-in).
  document.addEventListener('DOMContentLoaded', function () {
    var cards = document.querySelectorAll('.hero-card, .feature-grid > div');
    cards.forEach(function (card, index) {
      card.style.opacity = '0';
      card.style.transform = 'translateY(12px)';
      card.style.transition = 'opacity 0.5s ease, transform 0.5s ease';
      setTimeout(function () {
        card.style.opacity = '1';
        card.style.transform = 'translateY(0)';
      }, 100 + index * 80);
    });
  });
})();
