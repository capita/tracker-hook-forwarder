require File.join(File.dirname(__FILE__), 'spec_helper')

describe PivotalHookProxy::Forwarding do
  before do
    PivotalHookProxy.reset_forwardings!
    @forwarding = PivotalHookProxy::Forwarding.new('http://foo.bar/pivotal_hook')
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
      lambda { PivotalHookProxy::Forwarding.new('ftp://foo.bar/pivotal_hook') }.must_raise(ArgumentError)
      lambda { PivotalHookProxy::Forwarding.new('telnet://foo.bar/pivotal_hook') }.must_raise(ArgumentError)
    end
  end

  describe "configuration" do
    it "should be empty initially" do
      PivotalHookProxy.forwardings.empty?.must_equal true
    end

    it "should not be empty after adding a forwarding" do
      PivotalHookProxy.add_forwarding 'awesome_project', 'https://foo'
      PivotalHookProxy.forwardings.empty?.must_equal false
      PivotalHookProxy.forwardings.keys.must_equal [:awesome_project]
    end

    describe "having multiple forwardings configured" do
      before do
        PivotalHookProxy.add_forwarding 'awesome_project', 'https://foo'
        PivotalHookProxy.add_forwarding :awesome_project, 'http://foo.com'
        PivotalHookProxy.add_forwarding :other_project, 'http://foo.com'
      end

      it "should have the 2 projects configured" do
        PivotalHookProxy.forwardings.keys.sort.must_equal [:awesome_project, :other_project]
      end
      it "should have 2 forwardings for awesome_project" do
        PivotalHookProxy.forwardings_for(:awesome_project).count.must_equal 2
        PivotalHookProxy.forwardings_for(:awesome_project).first.url.must_equal 'https://foo'
        PivotalHookProxy.forwardings_for("awesome_project").last.url.must_equal 'http://foo.com'
      end

      it "should have 1 forwarding for the other project" do
        PivotalHookProxy.forwardings_for(:other_project).count.must_equal 1
        PivotalHookProxy.forwardings_for(:other_project).first.url.must_equal 'http://foo.com'
      end

      it "should return nil for unknown_project for forwardings" do
        PivotalHookProxy.forwardings_for(:unknown_project).must_be_nil
      end

      it "should return nil for empty or nil project name" do
        PivotalHookProxy.forwardings_for('').must_be_nil
        PivotalHookProxy.forwardings_for(nil).must_be_nil
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

      PivotalHookProxy.add_forwarding 'awesome_project', 'https://awesome.com/project'
      PivotalHookProxy.add_forwarding 'awesome_project', 'https://awesome.com/404'
    end

    it "should forward the given body to our configured valid endpoint" do
      PivotalHookProxy.forwardings_for('awesome_project').first.forward('<myxml></myxml>').must_equal true
    end

    it "should forward the given body to our configured invalid endpoint and handle failure gracefully" do
      PivotalHookProxy.forwardings_for('awesome_project').last.forward('<myxml></myxml>').must_equal false
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

      PivotalHookProxy.add_forwarding 'awesome_project', 'https://awesome.com/project/?token=123123asdf&room=abcdef'
    end

    it "should forward the given body to our configured valid endpoint including the expected params" do
      PivotalHookProxy.forwardings_for('awesome_project').first.forward('<myxml></myxml>').must_equal true
    end

    after do
      Artifice.deactivate
    end
  end
end