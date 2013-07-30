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
    it 'reads properties it responds to' do
      object = OpenStruct.new a: 1, b: 2
      object_accessor = Outbox::Accessor.new(object)
      expect(object_accessor[:a]).to eq(1)
      expect(object_accessor[:b]).to eq(2)
      expect(object_accessor[:c]).to be_nil
    end

    it 'writes properties it responds to' do
      object = OpenStruct.new a: nil
      object_accessor = Outbox::Accessor.new(object)
      object_accessor[:a] = 2
      object_accessor[:b] = 2
      expect(object_accessor.object.a).to eq(2)
      expect(object_accessor.object.b).to be_nil
    end
  end
end
