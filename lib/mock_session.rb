module MockSession
  def service(*a)
    @state = Camping::H.new()
    super
  end
end
