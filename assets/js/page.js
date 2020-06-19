const ready = fn => {
  if (document.readyState != 'loading'){
    fn();
  } else {
    document.addEventListener('DOMContentLoaded', fn);
  }
};

// newSecretPage
// ready(() => {
//   const viewUrlTxtElem = document.querySelector('#viewUrlTxt');
//   const viewUrlBtnElem = document.querySelector('#viewUrlBtn');

//   if (!viewUrlTxtElem || !viewUrlBtnElem) return;

//   if (navigator.share) {
//     viewUrlBtnElem.innerHTML = 'Share';
//     viewUrlBtnElem.setAttribute('aria-label', 'Share secret view link');
//     viewUrlBtnElem.addEventListener('click', event => {

//       navigator.share({title: 'Your secret view link', url: viewUrlTxtElem.value});
//     });
//   } else {
//     viewUrlBtnElem.addEventListener('click', event => {
//       viewUrlTxtElem.select();
//       document.execCommand('copy');
//     });
//   }

//   viewUrlTxtElem.select();
// });
