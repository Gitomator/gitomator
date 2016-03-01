require 'spec_helper'


describe Gitomator::Service::Hosting::Service do

  before(:each) do
    @hosting = create_hosting_service(ENV['GIT_HOSTING_PROVIDER'])
  end


  it "should not be nil" do
    expect(@hosting).not_to be_nil
  end


  it "create_repo should return a repo model-object" do
    repo = "test-repo-#{(Time.now.to_f * 1000).to_i}"
    expect(@hosting.create_repo(repo, {})).to be_a_kind_of(Gitomator::Model::Hosting::Repo)
  end


  it "read_repo should return a repo model-object" do
    repo = "test-repo-#{(Time.now.to_f * 1000).to_i}"
    @hosting.create_repo(repo, {})
    expect(@hosting.read_repo(repo)).to be_a_kind_of(Gitomator::Model::Hosting::Repo)
  end

  it "read_repo should return nil when repo doesn't exist" do
    repo = "non-existing-#{(Time.now.to_f * 1000).to_i}"
    expect(@hosting.read_repo(repo)).to be_nil
  end


end
