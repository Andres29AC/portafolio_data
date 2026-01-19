heading("{{title}}")

# Botón de navegación a la página de análisis
# row([
#     cell(class="col-md-12", [
#         a("🔬 Ir a Análisis y Machine Learning →", href="/analysis", style="color: #1976d2; text-decoration: underline; font-weight: bold; margin-bottom: 20px; display: inline-block; padding: 10px; background-color: #f0f0f0; border-radius: 4px;")
#     ])
# ])

row([
    cell(class="col-md-12", [
        uploader(
            multiple = true,
            accept = ".csv",
            maxfilesize = 1024*1024*1,
            maxfiles = 3,
            autoupload = true,
            hideuploadbtn = true,
            label = "Upload datasets",
            nothumbnails = true,
            style="max-width: 95%; width: 95%; margin: 0 auto;",

            @on("rejected", :rejected),
            @on("uploaded", :uploaded)
        )
    ])
])

row([
    cell(class="st-module", [
        h6("File")
        Stipple.select(:selected_file; options=:upfiles)
    ])
    cell(class="st-module", [
        h6("Column")
        Stipple.select(:selected_column; options=:columns)
    ])
])

row([
    cell(class="st-module", [
        h5("Histogram")
        plot(:trace, layout=:layout)
    ])
])

row([
    cell(class="st-module", [
        h5("Data Preview")
        Stipple.table(:table_data)
    ])
])

row([
    cell(class="st-module", [
        h5("Filtrado por Referencia")
        h6("Selecciona una referencia para filtrar los datos")
        Stipple.select(:selected_reference; options=:reference_options, label="Referencia")
    ])
])

row([
    cell(class="st-module", [
        h5("Datos Filtrados (Referencia y Magnitud)")
        Stipple.table(:filtered_table_data)
        br()
        p([
            a("Exportar a CSV", @on("click", "export_csv_clicked = export_csv_clicked + 1"), style="margin-right: 10px; padding: 8px 16px; background-color: #1976d2; color: white; text-decoration: none; border-radius: 4px; display: inline-block; cursor: pointer;"),
            a("Exportar a PDF", @on("click", "export_pdf_clicked = export_pdf_clicked + 1"), style="padding: 8px 16px; background-color: #6c757d; color: white; text-decoration: none; border-radius: 4px; display: inline-block; cursor: pointer;")
        ])
        script("""
        (function() {
            let lastCsvUrl = '';
            let lastPdfUrl = '';
            
            function checkDownloads() {
                const csvUrl = document.querySelector('[data-bind="csv_download_url"]')?.textContent || 
                               (window.Stipple && window.Stipple.app && window.Stipple.app.csv_download_url);
                const pdfUrl = document.querySelector('[data-bind="pdf_download_url"]')?.textContent || 
                               (window.Stipple && window.Stipple.app && window.Stipple.app.pdf_download_url);
                
                if (csvUrl && csvUrl !== lastCsvUrl && csvUrl.startsWith('/')) {
                    lastCsvUrl = csvUrl;
                    const link = document.createElement('a');
                    link.href = csvUrl;
                    link.download = csvUrl.split('/').pop();
                    link.style.display = 'none';
                    document.body.appendChild(link);
                    link.click();
                    setTimeout(() => document.body.removeChild(link), 100);
                }
                
                if (pdfUrl && pdfUrl !== lastPdfUrl && pdfUrl.startsWith('/')) {
                    lastPdfUrl = pdfUrl;
                    const link = document.createElement('a');
                    link.href = pdfUrl;
                    link.download = pdfUrl.split('/').pop();
                    link.style.display = 'none';
                    document.body.appendChild(link);
                    link.click();
                    setTimeout(() => document.body.removeChild(link), 100);
                }
            }
            
            // Verificar cada 500ms
            setInterval(checkDownloads, 500);
            
            // También usar MutationObserver si está disponible
            if (window.MutationObserver) {
                const observer = new MutationObserver(checkDownloads);
                observer.observe(document.body, { childList: true, subtree: true });
            }
        })();
        """)
    ])
])
