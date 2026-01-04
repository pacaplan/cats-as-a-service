class AdminController < ApplicationController
  before_action :authenticate_admin!

  # GET /admin
  # Admin dashboard (requires authentication)
  def index
    render html: admin_html.html_safe
  end

  private

  def authenticate_admin!
    unless warden.authenticated?(:admin_identity)
      redirect_to "/admin/sign_in"
    end
  end

  def current_admin
    warden.user(:admin_identity)
  end

  def admin_html
    require "erb"
    username = ERB::Util.html_escape(current_admin&.username || "Admin")
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
            .sign-out {
              margin-top: 20px;
            }
            .sign-out form {
              display: inline;
            }
            .sign-out button {
              background-color: #dc3545;
              color: white;
              border: none;
              padding: 8px 16px;
              border-radius: 4px;
              cursor: pointer;
            }
            .sign-out button:hover {
              background-color: #c82333;
            }
          </style>
        </head>
        <body>
          <div class="container">
            <h1>Admin Dashboard</h1>
            <p>Welcome to the Cats as a Service admin interface, #{username}!</p>
            <p>You are successfully authenticated.</p>
            <div class="sign-out">
              <form action="/admin/sign_out" method="post">
                <input type="hidden" name="_method" value="delete">
                <input type="hidden" name="authenticity_token" value="#{form_authenticity_token}">
                <button type="submit">Sign Out</button>
              </form>
            </div>
          </div>
        </body>
      </html>
    HTML
  end
end
