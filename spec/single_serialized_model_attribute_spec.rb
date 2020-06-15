require 'spec_helper'

RSpec.describe "AttrJson::Model with ActiveRecord serialize to one column" do


  let(:embedded_model_class) do
    Class.new do
      include AttrJson::Model

      attr_json :str, :string
      attr_json :int, :integer
    end
  end


  let(:record_class) do
    type_as_serializer = embedded_model_class.to_type

    Class.new(ActiveRecord::Base) do
      self.table_name = "products"

      serialize :other_attributes, type_as_serializer
    end
  end


  let(:record_instance) { record_class.new }


  let(:embedded_model_attributes) { { str: "value", int: 10 } }

  it "can be nil" do
    expect(record_instance.other_attributes).to be_nil

    record_instance.save!
    expect(record_instance.other_attributes).to be_nil

    record_instance.reload
    expect(record_instance.other_attributes).to be_nil
  end

  it "can assign and save from model class" do
    model_value = embedded_model_class.new(embedded_model_attributes)
    record_instance.other_attributes = model_value
    expect(record_instance.other_attributes).to eq(model_value)

    record_instance.save!
    expect(record_instance.other_attributes).to eq(model_value)

    record_instance.reload
    expect(record_instance.other_attributes).to eq(model_value)

    new_fetched_record_instance = record_class.find(record_instance.id)
    expect(new_fetched_record_instance.other_attributes).to eq(model_value)
  end

  it "will cast from hash" do
    record_instance.other_attributes = embedded_model_attributes
    expect(record_instance.other_attributes).to eq(embedded_model_class.new(embedded_model_attributes))

    record_instance.save!
    expect(record_instance.other_attributes).to eq(embedded_model_class.new(embedded_model_attributes))

    record_instance.reload
    expect(record_instance.other_attributes).to eq(embedded_model_class.new(embedded_model_attributes))

    new_fetched_record_instance = record_class.find(record_instance.id)
    expect(new_fetched_record_instance.other_attributes).to eq(embedded_model_class.new(embedded_model_attributes))
  end

  describe "with existing value" do
    let(:record_instance) { record_class.new(other_attributes: embedded_model_attributes)}

    it "can set to nil" do
      record_instance.other_attributes = nil
      expect(record_instance.other_attributes).to be_nil

      record_instance.save!
      expect(record_instance.other_attributes).to be_nil

      record_instance.reload
      expect(record_instance.other_attributes).to be_nil
    end
  end


  xit "for non-castable primitive" do
    expect {
      record_instance.other_attributes = 4
    }.to raise_error
  end
end
