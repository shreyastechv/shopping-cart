$(document).ready(function () {
    const carousel = $(".carousel.productList");

    carousel.carousel({
        interval: 500,
        pause: false,
        wrap: true
    }).carousel('pause');

    carousel.on("mouseenter", function () {
        $(this).carousel('cycle');
    }).on("mouseleave", function () {
        $(this).carousel('pause');
        $(this).carousel(0);
    });
});
