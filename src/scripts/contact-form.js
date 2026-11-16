// Contact form: validates, then posts JSON to the contact Lambda behind API Gateway.
// The endpoint comes from the hidden "endpoint" input in index.html.

export function initContactForm() {
  const form = document.getElementById('contact-form');
  const status = form.querySelector('.contact-status');
  const submit = form.querySelector('button[type="submit"]');
  const endpoint = form.elements.endpoint.value.trim();
  const configured = /^https?:\/\//.test(endpoint);

  const setStatus = (text, kind) => {
    status.textContent = text;
    status.className = 'contact-status' + (kind ? ' ' + kind : '');
  };

  form.addEventListener('submit', async e => {
    e.preventDefault();
    const data = {
      name: form.elements.name.value.trim(),
      email: form.elements.email.value.trim(),
      subject: form.elements.subject.value.trim(),
      message: form.elements.message.value.trim(),
    };
    const emailOk = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(data.email);
    form.elements.email.closest('.contact-field').classList.toggle('invalid', !emailOk);
    form.elements.message.closest('.contact-field').classList.toggle('invalid', !data.message);
    if (!emailOk || !data.message) {
      setStatus('Please add a valid email address and a message.', 'err');
      return;
    }
    if (!configured) {
      setStatus('The contact form is not connected yet. Please try again later.', 'err');
      return;
    }
    submit.disabled = true;
    setStatus('Sending…');
    try {
      const res = await fetch(endpoint, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', Accept: 'application/json' },
        body: JSON.stringify(data),
      });
      const body = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(body.message || 'Your message could not be sent. Please try again.');
      form.reset();
      setStatus(body.message || 'Your message has been sent.', 'ok');
    } catch (err) {
      setStatus(err.message || 'Your message could not be sent. Please try again.', 'err');
    } finally {
      submit.disabled = false;
    }
  });
}
