class AdminController < ApplicationController
  # GET /admin
  # Simple admin interface (no authentication for now)
  def index
    render html: admin_html.html_safe
  end

  private

  def admin_html
    <<~HTML
      <!DOCTYPE html>
      <html>
        <head>
          <title>Admin - Cats as a Service</title>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <style>
            body {
              font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
              max-width: 800px;
              margin: 50px auto;
              padding: 20px;
              background-color: #f5f5f5;
            }
            .container {
              background: white;
              padding: 40px;
              border-radius: 8px;
              box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            }
            h1 {
              color: #333;
              margin-top: 0;
            }
            p {
              color: #666;
              line-height: 1.6;
            }
          </style>
        </head>
        <body>
          <div class="container">
            <h1>Hello World</h1>
            <p>Welcome to the Cats as a Service admin interface.</p>
            <p>This is a non-API endpoint with no authentication (for now).</p>
          </div>
        </body>
      </html>
    HTML
  end
end
