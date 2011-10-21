require File.join(File.dirname(__FILE__), 'spec_helper')

describe TrackerHookForwarder::Forwarding do
  before do
    TrackerHookForwarder.reset_forwardings!
    @forwarding = TrackerHookForwarder::Forwarding.new('http://foo.bar/pivotal_hook')
  end

  describe 'url' do
    it "should return the correct url" do
      @forwarding.url.must_equal 'http://foo.bar/pivotal_hook'
    end
    it "should have freezed the url" do
      @forwarding.url.frozen?.must_equal true
      lambda { @forwarding.url.gsub!('http', 'https') }.must_raise(RuntimeError)
    end
    it "should raise an error when the url is not http(s)" do
      lambda { TrackerHookForwarder::Forwarding.new('ftp://foo.bar/pivotal_hook') }.must_raise(ArgumentError)
      lambda { TrackerHookForwarder::Forwarding.new('telnet://foo.bar/pivotal_hook') }.must_raise(ArgumentError)
    end
  end

  describe "configuration" do
    it "should be empty initially" do
      TrackerHookForwarder.forwardings.empty?.must_equal true
    end

    it "should not be empty after adding a forwarding" do
      TrackerHookForwarder.add_forwarding 'awesome_project', 'https://foo'
      TrackerHookForwarder.forwardings.empty?.must_equal false
      TrackerHookForwarder.forwardings.keys.must_equal [:awesome_project]
    end

    describe "having multiple forwardings configured" do
      before do
        TrackerHookForwarder.add_forwarding 'awesome_project', 'https://foo'
        TrackerHookForwarder.add_forwarding :awesome_project, 'http://foo.com'
        TrackerHookForwarder.add_forwarding :other_project, 'http://foo.com'
      end

      it "should have the 2 projects configured" do
        TrackerHookForwarder.forwardings.keys.sort.must_equal [:awesome_project, :other_project]
      end
      it "should have 2 forwardings for awesome_project" do
        TrackerHookForwarder.forwardings_for(:awesome_project).count.must_equal 2
        TrackerHookForwarder.forwardings_for(:awesome_project).first.url.must_equal 'https://foo'
        TrackerHookForwarder.forwardings_for("awesome_project").last.url.must_equal 'http://foo.com'
      end

      it "should have 1 forwarding for the other project" do
        TrackerHookForwarder.forwardings_for(:other_project).count.must_equal 1
        TrackerHookForwarder.forwardings_for(:other_project).first.url.must_equal 'http://foo.com'
      end

      it "should return nil for unknown_project for forwardings" do
        TrackerHookForwarder.forwardings_for(:unknown_project).must_be_nil
      end

      it "should return nil for empty or nil project name" do
        TrackerHookForwarder.forwardings_for('').must_be_nil
        TrackerHookForwarder.forwardings_for(nil).must_be_nil
      end
    end
  end

  describe "forwarding to an actual endpoint" do
    before do
      # Simple rack app that receives the POSTs from the forwarding
      Artifice.activate_with lambda { |env|
        request = Rack::Request.new(env)
        body = request.body.read
        if request.fullpath == '/project'
          raise "Requst should have been post!" unless request.post?
          raise "Wrong url: #{request.url}" unless request.url == 'https://awesome.com/project'
          raise "Wrong body: #{body}" unless body == '<myxml></myxml>'
          [200, {}, []]
        else
          [404, {}, []]
        end
      }

      TrackerHookForwarder.add_forwarding 'awesome_project', 'https://awesome.com/project'
      TrackerHookForwarder.add_forwarding 'awesome_project', 'https://awesome.com/404'
    end

    it "should forward the given body to our configured valid endpoint" do
      TrackerHookForwarder.forwardings_for('awesome_project').first.forward('<myxml></myxml>').must_equal true
    end

    it "should forward the given body to our configured invalid endpoint and handle failure gracefully" do
      TrackerHookForwarder.forwardings_for('awesome_project').last.forward('<myxml></myxml>').must_equal false
    end

    after do
      Artifice.deactivate
    end
  end

  describe "forwarding to an endpoint with query params" do
    before do
      # Simple rack app that receives the POSTs from the forwarding
      Artifice.activate_with lambda { |env|
        request = Rack::Request.new(env)
        raise "Wrong token passed on!" if request.params["token"] != '123123asdf'
        raise "Wrong room passed on!" if request.params["room"] != 'abcdef'
        [200, {}, []]
      }

      TrackerHookForwarder.add_forwarding 'awesome_project', 'https://awesome.com/project/?token=123123asdf&room=abcdef'
    end

    it "should forward the given body to our configured valid endpoint including the expected params" do
      TrackerHookForwarder.forwardings_for('awesome_project').first.forward('<myxml></myxml>').must_equal true
    end

    after do
      Artifice.deactivate
    end
  end
end