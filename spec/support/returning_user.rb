module ReturningUser

  def create_returning(client, user)
    @returning_user = "returning_user@email.com"
    user[:email] = @returning_user
    client.create_registration(user)
  end

end