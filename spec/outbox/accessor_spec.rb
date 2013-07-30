require 'spec_helper'

describe Outbox::Accessor do
  context 'with a hash' do
    it 'reads properties via symbol' do
      hash = { 'a' => 1, :b => 2 }
      hash_accessor = Outbox::Accessor.new(hash)
      expect(hash_accessor[:a]).to eq(1)
      expect(hash_accessor[:b]).to eq(2)
      expect(hash_accessor[:c]).to be_nil
    end

    it 'reads properties via string' do
      hash = { 'a' => 1, :b => 2 }
      hash_accessor = Outbox::Accessor.new(hash)
      expect(hash_accessor['a']).to eq(1)
      expect(hash_accessor['b']).to eq(2)
      expect(hash_accessor['c']).to be_nil
    end

    it 'writes arbitrary properties' do
      hash = {}
      hash_accessor = Outbox::Accessor.new(hash)
      hash_accessor[:a] = 1
      hash_accessor['b'] = 2
      expect(hash_accessor.object[:a]).to eq(1)
      expect(hash_accessor.object[:b]).to eq(2)
    end
  end

  context 'with an object' do
    class MockObj
      attr_accessor :a, :b
    end

    it 'reads properties it responds to' do
      object = MockObj.new
      object.a = 1
      object.b = 2
      object_accessor = Outbox::Accessor.new(object)
      expect(object_accessor[:a]).to eq(1)
      expect(object_accessor[:b]).to eq(2)
      expect(object_accessor[:c]).to be_nil
    end

    it 'writes properties it responds to' do
      object = MockObj.new
      object.a = 1
      object_accessor = Outbox::Accessor.new(object)
      expect(object_accessor[:a]).to eq(1)
      object_accessor[:a] = 2
      expect(object_accessor.object.a).to eq(2)
      expect {
        object_accessor[:c] = 2
      }.not_to raise_error()
    end
  end
end
