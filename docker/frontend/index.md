---
layout: default
title: "Timur's Quote Page!"
---

## 🌟 Welcome to Timur's Quote Site - Kubernetes - Jekyll - Helm 🌟

### Quote of the day: <span id="quote">Loading...</span>

**Loaded at:** <span id="timestamp">Loading...</span>

<script>
  fetch('/quote')
    .then(response => response.json())
    .then(data => {
      document.getElementById('quote').innerText = data.quote;
      document.getElementById('timestamp').innerText = new Date().toLocaleString();
    })
    .catch(err => {
      document.getElementById('quote').innerText = 'Error loading quote';
      document.getElementById('timestamp').innerText = new Date().toLocaleString();
    });
</script>
## Contact

You can find me on:
- GitHub: [timursamanchi](https://github.com/timursamanchi)