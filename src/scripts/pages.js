// Panel navigation: one section shows at a time. Handles nav links, swipe
// gestures, the staggered entrance animation and deep links like #projects.

export function initPages() {
  const nav = document.getElementById('nav');
  const links = [...document.querySelectorAll('.links a, .btn-talk')];
  const pages = document.getElementById('pages');
  const panels = [...pages.children];
  let current = 0;
  let leaveTimer;
  let enterTimer;
  const reduceMotion = matchMedia('(prefers-reduced-motion: reduce)').matches;
  // How long the old panel fades on its own before the new one starts coming in.
  const ENTER_DELAY = reduceMotion ? 0 : 220;
  // How long the old panel stays on screen (its fade, plus the first few staggered elements).
  const LEAVE_TIME = reduceMotion ? 0 : 520;

  // Elements that animate in one after another, in this order, per panel.
  const REVEAL = '.pill, h1, .lede, .btn, .photo, .stat, .ribbon-clip, .about h2, .about-main p, .about-card, .skills h2, .skills-lede, .skill-card, .core-stack, .projects h2, .project-card, .contact h2, .contact-lede, .contact-item, .contact-field, .socials h3, .social-card';
  panels.forEach(panel => panel.querySelectorAll(REVEAL).forEach((el, i) => {
    el.classList.add('reveal');
    el.style.setProperty('--i', i);
  }));

  // Show a panel and replay its entrance. dx/dy say where its elements travel in from.
  function playEntrance(panel, dx, dy) {
    panels.forEach(x => x.classList.remove('is-active'));
    panel.style.setProperty('--dx', dx + 'px');
    panel.style.setProperty('--dy', dy + 'px');
    void panel.offsetWidth;                 // restart the CSS animations
    panel.classList.add('is-active');
  }

  // Highlight every nav item that points at the same panel (e.g. "Let's talk" and the mobile "Contact").
  const setActiveLink = link => {
    const href = link && link.getAttribute('href');
    links.forEach(x => x.classList.toggle('active', x.getAttribute('href') === href));
  };
  const linkFor = panel => links.find(x => x.getAttribute('href') === '#' + panel.id);

  // Switch straight from the current panel to the chosen one; panels in between are never shown.
  function show(index) {
    const previous = current;
    if (index === previous) return;
    current = index;
    clearTimeout(leaveTimer);
    clearTimeout(enterTimer);
    panels.forEach(x => x.classList.remove('is-leaving'));

    // Travel direction follows the nav order: later panels come in from the right, earlier from the left.
    const forward = index > previous;
    const leaving = panels[previous];
    leaving.style.setProperty('--ox', (forward ? -70 : 70) + 'px');
    leaving.classList.remove('is-active');
    leaving.classList.add('is-leaving');
    leaveTimer = setTimeout(() => leaving.classList.remove('is-leaving'), LEAVE_TIME);

    enterTimer = setTimeout(() => playEntrance(panels[index], forward ? 70 : -70, 0), ENTER_DELAY);
  }

  // In-page links: switch to the panel that holds the target, then scroll down to it.
  document.querySelectorAll('a[href^="#"]').forEach(a => a.addEventListener('click', e => {
    nav.classList.remove('open');
    const target = document.getElementById(a.getAttribute('href').slice(1));
    const panel = target && target.closest('.page');
    if (!panel) return;
    e.preventDefault();
    const index = panels.indexOf(panel);
    const changing = index !== current;
    show(index);
    if (target === panel) {
      window.scrollTo({ top: 0, behavior: changing ? 'instant' : 'smooth' });
    } else {
      // The target is inside the incoming panel, which is laid out once it appears.
      setTimeout(() => window.scrollTo({ top: target.getBoundingClientRect().top + window.scrollY - 20, behavior: 'smooth' }),
        changing ? ENTER_DELAY + 20 : 0);
    }
    const link = links.find(x => x.getAttribute('href') === a.getAttribute('href'));
    if (link) setActiveLink(link);
    history.replaceState(null, '', a.getAttribute('href'));
  }));

  // Swiping sideways on a touch screen moves one panel left or right.
  let touch = null;
  pages.addEventListener('touchstart', e => {
    touch = e.touches.length === 1 ? { x: e.touches[0].clientX, y: e.touches[0].clientY } : null;
  }, { passive: true });
  pages.addEventListener('touchend', e => {
    if (!touch) return;
    const dx = e.changedTouches[0].clientX - touch.x;
    const dy = e.changedTouches[0].clientY - touch.y;
    touch = null;
    if (Math.abs(dx) < 70 || Math.abs(dx) < Math.abs(dy) * 1.5) return;
    const index = current + (dx < 0 ? 1 : -1);
    if (!panels[index]) return;
    show(index);
    window.scrollTo({ top: 0, behavior: 'instant' });
    setActiveLink(linkFor(panels[index]));
    history.replaceState(null, '', '#' + panels[index].id);
  }, { passive: true });

  // First load: elements rise into place.
  const startAt = panels.findIndex(panel => '#' + panel.id === location.hash);
  if (startAt > 0) {
    current = startAt;
    setActiveLink(linkFor(panels[startAt]));
    // The browser's own jump to #about / #projects scrolls the window down past the nav.
    // Clear the hash while the page loads so that jump never happens, then put it back.
    const hash = location.hash;
    if ('scrollRestoration' in history) history.scrollRestoration = 'manual';
    history.replaceState(null, '', location.pathname + location.search);
    window.scrollTo(0, 0);
    addEventListener('load', () => {
      window.scrollTo(0, 0);
      history.replaceState(null, '', hash);
    }, { once: true });
  }
  playEntrance(panels[current], 0, 44);
}
