defmodule ViralSpiral.Accounts do
  import Ecto.Query
  alias ViralSpiral.Repo
  alias ViralSpiral.Accounts.User

  def get_user(id), do: Repo.get(User, id)

  def get_user!(id), do: Repo.get!(User, id)

  def get_user_by_email(email) do
    Repo.get_by(User, email: String.downcase(email))
  end

  def register_user(attrs) do
    attrs = Map.update(attrs, "email", nil, &String.downcase/1)

    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Authenticate a user by email and password.
  Returns `{:ok, user}` on success, `{:error, :invalid_credentials}` on failure.
  Uses Bcrypt.no_user_verify/0 on miss to prevent timing attacks.
  """
  def authenticate_user(email, password) do
    user = get_user_by_email(email)

    cond do
      user && Bcrypt.verify_pass(password, user.password_hash) ->
        {:ok, user}

      user ->
        {:error, :invalid_credentials}

      true ->
        Bcrypt.no_user_verify()
        {:error, :invalid_credentials}
    end
  end

  def update_profile(%User{} = user, attrs) do
    user
    |> User.profile_changeset(attrs)
    |> Repo.update()
  end

  def list_users_by_email(emails) when is_list(emails) do
    emails = Enum.map(emails, &String.downcase/1)

    User
    |> where([u], u.email in ^emails)
    |> Repo.all()
  end
end
