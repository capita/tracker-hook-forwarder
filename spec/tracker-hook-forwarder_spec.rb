require File.join(File.dirname(__FILE__), 'spec_helper')

describe TrackerHookForwarder do
  include Rack::Test::Methods
  include RR::Adapters::TestUnit

  def app
    TrackerHookForwarder
  end

  before { TrackerHookForwarder.reset_forwardings! }

  describe "GET /" do
    before(:each) { get "/" }
    it "should respond with status 200" do
      last_response.status.must_equal 200
    end
    it "should give a greeting in response body" do
      last_response.body.must_equal "Hello."
    end
    it "should respond with Content-Type text/plain" do
      last_response.headers["Content-Type"].must_equal 'text/plain'
    end
  end

  describe "POST /" do
    before(:each) { post "/" }
    it "should respond with status 404" do
      last_response.status.must_equal 404
    end
  end

  describe "GET /foobar" do
    before(:each) { get "/foobar" }
    it "should respond with status 404" do
      last_response.status.must_equal 404
    end
    it "should give an error in response body" do
      last_response.body.must_equal "Resource not found"
    end
    it "should respond with Content-Type text/plain" do
      last_response.headers["Content-Type"].must_equal 'text/plain'
    end
  end

  describe "POST /activity/unknown" do
    before(:each) { post '/activity/unknown', "<xml></xml>" }
    it "should respond with status 404" do
      last_response.status.must_equal 404
    end
    it "should give an error in response body" do
      last_response.body.must_equal "Resource not found"
    end
  end

  describe "POST /activity/my_project with forwardings" do
    before(:each) do
      TrackerHookForwarder.add_forwarding 'my_project', 'http://localhost:9292'

      # Expect forward method to be called on this only forwarding, using the request body
      # and returning true
      mock(TrackerHookForwarder.forwardings_for(:my_project).first).forward('<xml></xml>') { true }

      post '/activity/my_project', "<xml></xml>"
    end
    it "should respond with status 201" do
      last_response.status.must_equal 201
    end
    it "should echo the request body" do
      last_response.body.must_equal "<xml></xml>"
    end
  end
end