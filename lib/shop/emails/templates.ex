defmodule Shop.Emails do
  import Swoosh.Email

  def welcome_email(user, token) do
    new()
    |> to({user.first_name <> " " <> user.last_name, user.email})
    |> from({"Shop Support", "support@shop.com"})
    |> subject("Welcome to Shop 🎉")
    |> html_body("""
      <div style="font-family: Roobert, Arial, sans-serif; line-height: 1.6; color: white; max-width: 600px; margin: auto;">
        <h1 style="color: #4ea1ff;">Welcome, #{user.first_name}!</h1>
        <p>Thanks for joining <strong>Shop</strong>. We're excited to have you onboard 🎊</p>
        <p>Use the verification code below to activate your account:</p>
        <p style="text-align: center; font-size: 26px; font-weight: bold; letter-spacing: 4px; color: #4ea1ff; margin: 30px 0;">
          ${token}
        </p>
        <p>This code will expire in <strong>15 minutes</strong>.</p>
        <hr style="border: none; border-top: 1px solid #ddd; margin: 30px 0;" />
        <p style="font-size: 12px; color: #888;">If you didn’t sign up for Shop, you can safely ignore this email.</p>
      </div>
    """)
    |> text_body("""
    Welcome, #{user.first_name}!

    Thanks for joining Shop. We're excited to have you onboard 🎊

    Your verification code is: #{token}

    This code will expire in 15 minutes.

    If you didn’t sign up for Shop, you can safely ignore this email.
    """)
  end

  def verification_email(user, token) do
    new()
    |> to({user.first_name <> " " <> user.last_name, user.email})
    |> from({"Shop Support", "support@shop.com"})
    |> subject("Account verification request")
    |> html_body("""
      <div style="font-family: Roobert, Arial, sans-serif; line-height: 1.6; color: white; max-width: 600px; margin: auto;">
        <h1 style="color: #4ea1ff;">Welcome, #{user.first_name}!</h1>
        <p>Thanks for joining <strong>Shop</strong>. We're excited to have you onboard 🎊</p>
        <p>Use the verification code below to activate your account:</p>
        <p style="text-align: center; font-size: 26px; font-weight: bold; letter-spacing: 4px; color: #4ea1ff; margin: 30px 0;">
          #{token}
        </p>
        <p>This code will expire in <strong>15 minutes</strong>.</p>
        <hr style="border: none; border-top: 1px solid #ddd; margin: 30px 0;" />
        <p style="font-size: 12px; color: #888;">If you didn’t sign up for Shop, you can safely ignore this email.</p>
      </div>
    """)
    |> text_body("""
    Welcome, #{user.first_name}!

    Thanks for joining Shop. We're excited to have you onboard 🎊

    Your verification code is: #{token}

    This code will expire in 15 minutes.

    If you didn’t sign up for Shop, you can safely ignore this email.
    """)
  end

  def password_reset_email(user, token) do
    reset_url = "https://frontend.com/reset-password?token=#{token}"

    new()
    |> to({user.first_name <> " " <> user.last_name, user.email})
    |> from({"Shop Support", "support@shop.com"})
    |> subject("Reset your password")
    |> html_body("""
      <div style="background-color: #f5f5f5; padding: 40px; font-family: Roobert, sans-serif;">
        <div style="max-width: 600px; margin: 0 auto; background-color: #1e1e1e; padding: 30px; border-radius: 10px; color: white;">
          <h2 style="color: #4ea1ff; text-align: center;">Password Reset Request</h2>
          <p>Hello #{user.first_name},</p>
          <p>We received a request to reset your password. Click the button below to proceed:</p>
          <p style="text-align: center; margin: 30px 0;">
            <a href="#{reset_url}" style="
              background-color: #4ea1ff;
              color: white;
              padding: 12px 25px;
              text-decoration: none;
              border-radius: 5px;
              display: inline-block;
              font-weight: bold;
            ">Reset Password</a>
          </p>
          <p style="font-size: 14px; color: #cccccc;">
            This link will expire in 15 minutes.
          </p>
          <p style="font-size: 14px; color: #cccccc;">
            If you did not request a password reset, you can safely ignore this email.
          </p>
        </div>
      </div>
    """)
    |> text_body("""
      Hello #{user.first_name},

      We received a request to reset your password. Use the link below to reset it:

      #{reset_url}

      This link will expire in 15 minutes.

      If you did not request a password reset, you can safely ignore this email.
    """)
  end
end
