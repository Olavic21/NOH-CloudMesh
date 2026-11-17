/**
 * N.O.H. CloudMesh – Maquettes interactives
 * Application JS pour le fonctionnement des maquettes
 */

document.addEventListener('DOMContentLoaded', () => {
  // Device view switching
  const deviceButtons = document.querySelectorAll('.seg button');
  deviceButtons.forEach(btn => {
    btn.addEventListener('click', () => {
      // Remove 'on' class from all buttons
      deviceButtons.forEach(b => b.classList.remove('on'));
      // Add 'on' class to clicked button
      btn.classList.add('on');
    });
  });

  // Theme/role switching
  const roleButtons = document.querySelectorAll('#sr button');
  roleButtons.forEach(btn => {
    btn.addEventListener('click', () => {
      roleButtons.forEach(b => b.classList.remove('on'));
      btn.classList.add('on');
    });
  });

  // Mobile/Desktop view toggle
  const mobileBtn = document.querySelector('button[data-v="mobile"]');
  const desktopBtn = document.querySelector('button[data-v="desktop"]');
  const deviceDiv = document.querySelector('#dev.device');

  if (mobileBtn && desktopBtn && deviceDiv) {
    mobileBtn.addEventListener('click', () => {
      mobileBtn.classList.add('on');
      desktopBtn.classList.remove('on');
      deviceDiv.classList.add('mobile');
      deviceDiv.classList.remove('desktop');
    });

    desktopBtn.addEventListener('click', () => {
      desktopBtn.classList.add('on');
      mobileBtn.classList.remove('on');
      deviceDiv.classList.add('desktop');
      deviceDiv.classList.remove('mobile');
    });
  }

  // Initialize to mobile view by default
  if (mobileBtn) mobileBtn.click();
});