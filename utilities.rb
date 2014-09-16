class Hash

  def permit(*args)
    self.select do |k, v|
      args.include?(k)
    end
  end

end