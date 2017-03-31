shared_context "time frozen" do |time = nil|
  around do |example|
    Timecop.freeze(time)
    example.run
    Timecop.return
  end
end
