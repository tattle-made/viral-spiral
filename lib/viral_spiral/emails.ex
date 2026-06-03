defmodule ViralSpiral.Emails do
  import Swoosh.Email
  alias ViralSpiral.Mailer

  @from {"Game Platform", "noreply@viralspiral.net"}

  @doc "Invite email for users who don't yet have an account."
  def invite_new_user(email, game_name, role, invite_token, base_url) do
    invite_url = "#{base_url}/invites/#{invite_token}"
    role_label = role_label(role)

    new()
    |> to(email)
    |> from(@from)
    |> subject("You've been invited to #{game_name} as a #{role_label}")
    |> html_body("""
    <p>You've been invited to join <strong>#{game_name}</strong> as a <strong>#{role_label}</strong>.</p>
    <p>Create your account to accept the invitation:</p>
    <p><a href="#{invite_url}">#{invite_url}</a></p>
    <p>This link expires in 7 days.</p>
    """)
    |> text_body("""
    You've been invited to join #{game_name} as a #{role_label}.

    Create your account to accept the invitation:
    #{invite_url}

    This link expires in 7 days.
    """)
    |> Mailer.deliver()
  end

  @doc "Notification email for existing users who are directly added to a game."
  def notify_existing_user(email, game_name, role, base_url) do
    game_url = "#{base_url}/games"
    role_label = role_label(role)

    new()
    |> to(email)
    |> from(@from)
    |> subject("You've been added to #{game_name} as a #{role_label}")
    |> html_body("""
    <p>You've been added to <strong>#{game_name}</strong> as a <strong>#{role_label}</strong>.</p>
    <p><a href="#{game_url}">View your games</a></p>
    """)
    |> text_body("""
    You've been added to #{game_name} as a #{role_label}.

    View your games: #{game_url}
    """)
    |> Mailer.deliver()
  end

  defp role_label(:collaborator), do: "collaborator"
  defp role_label(:playtester), do: "playtester"
end
