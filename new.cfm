<input type="file" id="fileInput" multiple accept="image/*">
<div id="imagePreview"></div>

<script>
$(document).ready(function () {
    $("#fileInput").on("change", function () {
        let files = this.files;
        let dt = new DataTransfer();
        let previewContainer = $("#imagePreview").empty(); // Clear previous previews

        $.each(files, function (i, file) {
            if (file.type.startsWith("image/") && file.size <= 200 * 1024) {
                dt.items.add(file);

                // Create image preview
                let imgDiv = $(`
                    <div style="display:inline-block; margin:10px; border:1px solid #ccc; padding:5px; border-radius:5px; text-align:center;">
                        <img src="${URL.createObjectURL(file)}" style="width:100px; height:100px; object-fit:cover; display:block; margin-bottom:5px;">
                        <p style="font-size:12px; color:#555;">${file.name}</p>
                    </div>
                `);
                previewContainer.append(imgDiv);
            }
        });

        this.files = dt.files; // Update input with filtered files
    });
});
</script>
