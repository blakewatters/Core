require File.expand_path('../../spec_helper', __FILE__)

module Pod
  describe Podfile::TargetDefinition do
    describe "In general" do

      before do
        @app_def = Podfile::TargetDefinition.new("MyApp", nil, Podfile.new {})
        @app_def.target_dependencies << Dependency.new('BlocksKit')
        @app_def.platform = Platform.new(:ios, '6.0')
        @test_def = Podfile::TargetDefinition.new(:MyAppTests, @app_def, nil)
        @test_def.target_dependencies << Dependency.new('OCMockito')
      end

      it "returns its name" do
        @app_def.name.should == "MyApp"
        @test_def.name.should == :MyAppTests
      end

      it "returns its app_def" do
        @app_def.parent.should.be.nil
        @test_def.parent.should == @app_def
      end

      it "returns the podfile that specifies it" do
        @app_def.podfile.class.should == Podfile
      end

      it "returns its target dependencies" do
        @app_def.target_dependencies.map(&:name).should == %w[ BlocksKit ]
        @test_def.target_dependencies.map(&:name).should == %w[ OCMockito ]
      end

      it "returns whether it is empty" do
        @app_def.should.not.be.empty
        empty_def = Podfile::TargetDefinition.new(:empty, nil, nil)
        empty_def.should.be.empty
      end

      it "returns dependencies" do
        @app_def.dependencies.map(&:name).should  == %w[ BlocksKit ]
        @test_def.dependencies.map(&:name).should == %w[ OCMockito BlocksKit ]
      end

      it "returns if it is exclusive" do
        @app_def.should.not.be.exclusive
        @app_def.exclusive = true
        @app_def.should.be.exclusive
      end

      it "doesn't inherit dependencies if it is exclusive" do
        @test_def.exclusive = true
        @test_def.dependencies.map(&:name).should == %w[ OCMockito ]
      end

      it "returns the names of the targets that it should link with" do
        @app_def.link_with.should.be.nil
        @app_def.link_with = ['appTarget1, appTarget2']
        @app_def.link_with.should.be == ['appTarget1, appTarget2']
      end

      it "returns its platform" do
        @app_def.platform.should == Pod::Platform.new(:ios, '6.0')
      end

      it "returns its parent platform if none was specified" do
        @test_def.instance_variable_get('@platform').should.be.nil
        @test_def.platform.should == Pod::Platform.new(:ios, '6.0')
      end

      it "returns if it should inhibit all warnings" do
        @app_def.inhibit_all_warnings?.should == nil
        @app_def.inhibit_all_warnings = true
        @app_def.inhibit_all_warnings?.should == true
      end

      it "inherits the option to inhibit all warnings from the parent" do
        @test_def.inhibit_all_warnings?.should == nil
        @app_def.inhibit_all_warnings = true
        @test_def.inhibit_all_warnings?.should == true
      end

      it "returns the user project path if specified" do
        @app_def.user_project_path.should.be.nil
        @app_def.user_project_path = 'some/path/project.xcodeproj'
        @app_def.user_project_path.should == 'some/path/project.xcodeproj'
      end

      it "returns the project build configurations" do
        @app_def.build_configurations.should.be.nil
        @app_def.build_configurations = { 'Debug' => :debug, 'Release' => :release }
        @app_def.build_configurations.should == { 'Debug' => :debug, 'Release' => :release }
      end

      it "returns its label" do
        @app_def.label.should == 'Pods-MyApp'
      end

      it "returns `Pods` as the label if its name is default" do
        target_def = Podfile::TargetDefinition.new(:default, nil, nil)
        target_def.label.should == 'Pods'
      end

      it "includes the name of the parent in the label if any" do
        @test_def.label.should == 'Pods-MyApp-MyAppTests'
      end

      it "doesn't include the name of the parent in the label if it is exclusive" do
        @test_def.exclusive = true
        @test_def.label.should == 'Pods-MyAppTests'
      end
    end
  end
end
