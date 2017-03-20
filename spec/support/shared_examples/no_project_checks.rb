shared_examples "no project checks" do
  it "returns no project checks" do
    expect(subject).to eq([])
  end
end
