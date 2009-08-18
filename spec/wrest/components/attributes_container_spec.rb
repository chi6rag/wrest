# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

require File.dirname(__FILE__) + '/../../spec_helper'

module Wrest::Components
  describe AttributesContainer do
    class HumanBeing
      include Wrest::Components::AttributesContainer
      always_has :id
    end

    it "should provide a convenient macro to enable typecasting" do
      @Demon = Class.new

      @Demon.class_eval do
        include Wrest::Components::AttributesContainer
      end

      @Demon.should_not respond_to(:typecast)

      @Demon.class_eval do
        enable_typecasting_support
      end

      @Demon.should respond_to(:typecast)
    end

    it "should allow instantiation with no attributes" do
      lambda{ HumanBeing.new }.should_not raise_error
    end

    describe 'always_has' do
      describe 'method creation' do
        before :each do
          @Demon = Class.new
        end

        # Methods are string in 1.8 and symbols in 1.9. We'll use to_sym to
        # allow us to build on both.
        it "should define attribute getters at the class level" do
          kai_wren = @Demon.new
          kai_wren.methods.map(&:to_sym).should_not include(:trainer)

          @Demon.class_eval{
            include Wrest::Components::AttributesContainer
            always_has :trainer
          }

          kai_wren.methods.map(&:to_sym).should include(:trainer)
        end

        it "should define attribute setters at the class level" do
          kai_wren = @Demon.new
          kai_wren.methods.map(&:to_sym).should_not include(:trainer=)

          @Demon.class_eval{
            include Wrest::Components::AttributesContainer
            always_has :trainer
          }

          kai_wren.methods.map(&:to_sym).should include(:trainer=)
        end

        it "should define attribute query methods at the class level" do
          kai_wren = @Demon.new
          kai_wren.methods.map(&:to_sym).should_not include(:trainer?)

          @Demon.class_eval{
            include Wrest::Components::AttributesContainer
            always_has :trainer
          }
          kai_wren.methods.map(&:to_sym).should include(:trainer?)
        end
      end

      describe 'method functionality' do
        before :each do
          @Demon = Class.new
          @Demon.class_eval{
            include Wrest::Components::AttributesContainer
            always_has :trainer

            def method_missing(method_name, *args)
              # Ensuring that the instance level
              # attribute methods don't kick in
              # by overriding method_missing
              raise NoMethodError.new("Method #{method_name} was invoked, but doesn't exist", method_name)
            end
          }
          @kai_wren = @Demon.new
        end

        it "should define attribute getters at the class level" do
          @kai_wren.instance_variable_get("@attributes")[:trainer] = 'Viss'
          @kai_wren.trainer.should == 'Viss'
        end

        it "should define attribute setters at the class level" do
          @kai_wren.trainer = 'Viss'
          @kai_wren.instance_variable_get("@attributes")[:trainer].should == 'Viss'
        end

        it "should define attribute query methods at the class level" do
          @kai_wren.trainer?.should be_false
          @kai_wren.instance_variable_get("@attributes")[:trainer] = 'Viss'
          @kai_wren.trainer?.should be_true
        end
      end
    end

    describe 'provides an attributes interface which' do
      before :each do
        @li_piao = HumanBeing.new(:id => 5, :profession => 'Natural Magician', 'enhanced_by' => 'Kai Wren')
      end

      it "should provide a generic key based getter that requires symbols" do
        @li_piao[:profession].should == "Natural Magician"
        @li_piao['profession'].should == "Natural Magician"
      end

      it "should fail when getter methods for attributes that don't exist are invoked" do
        lambda{ @li_piao.ooga }.should raise_error(NoMethodError)
      end

      it "should provide getter methods for attributes" do
        @li_piao.profession.should == 'Natural Magician'
        @li_piao.enhanced_by.should == 'Kai Wren'
      end

      it "should respond to getter methods for attributes" do
        @li_piao.should respond_to(:profession)
        @li_piao.should respond_to(:enhanced_by)
      end

      it "should not respond to getter methods for attributes that don't exist" do
        @li_piao.should_not respond_to(:gods)
      end

      it "should provide a generic key based setter that understands symbols" do
        @li_piao[:enhanced_by] = "Viss"
        @li_piao.instance_variable_get('@attributes')[:enhanced_by].should == "Viss"
      end

      it "should provide a generic key based setter that translates strings to symbols" do
        @li_piao['enhanced_by'] = "Viss"
        @li_piao.instance_variable_get('@attributes')[:enhanced_by].should == "Viss"
      end

      it "should create a setter method when one is invoked for attributes that don't exist" do
        @li_piao.niece = 'Li Plum'
        @li_piao.instance_variable_get('@attributes')[:niece].should == 'Li Plum'
        @li_piao.niece.should == 'Li Plum'
      end

      it "should provide setter methods for attributes" do
        @li_piao.enhanced_by = 'He of the Towers of Light'
        @li_piao.instance_variable_get('@attributes')[:enhanced_by].should == 'He of the Towers of Light'
      end

      it "should respond to setter methods for attributes" do
        @li_piao.should respond_to(:profession=)
        @li_piao.should respond_to(:enhanced_by=)
      end

      it "should not respond to setter methods for attributes that don't exist" do
        @li_piao.should_not respond_to(:god=)
      end

      it "should fail when query methods for attributes that don't exist are invoked" do
        lambda{ @li_piao.ooga? }.should raise_error(NoMethodError)
      end

      it "should provide query methods for attributes" do
        li_piao = HumanBeing.new( :profession => 'Natural Magician', :enhanced_by => nil)
        li_piao.profession?.should be_true
        li_piao.enhanced_by?.should be_false
      end

      it "should respond to query methods for attributes" do
        @li_piao.should respond_to(:profession?)
        @li_piao.should respond_to(:enhanced_by?)
      end

      it "should not respond to query methods for attributes that don't exist" do
        @li_piao.should_not respond_to(:theronic?)
      end

      it "should override methods which already exist on the container" do
        @li_piao.id.should == 5
        @li_piao.id = 6
        @li_piao.id.should == 6
      end

      it "should provide getter and query methods to instance which has corresponding attribute" do
        zotoh_zhaan = HumanBeing.new(:species => "Delvian")
        zotoh_zhaan.species.should == "Delvian"
        zotoh_zhaan.species?.should be_true
        zotoh_zhaan.species = "Human"
        lambda{@li_piao.species}.should raise_error(NoMethodError)
        lambda{@li_piao.species?}.should raise_error(NoMethodError)
        @li_piao.should_not respond_to(:species=)
        @li_piao.methods.grep(/:species=/).should be_empty
      end
    end
  end
end
