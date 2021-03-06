require 'spec_helper'

describe UNHCRMapping do
  before do
    Child.any_instance.stub(:field_definitions).and_return([])
    SystemSettings.all.each &:destroy

    @system_settings = SystemSettings.create(default_locale: 'en',
                              case_code_format: ['created_by_user.code'],
                              unhcr_needs_codes_mapping: {
                                '_id' => 'needs_codes_mapping',
                                'autocalculate' => 'true',
                                'mapping' => {'protection ab' => 'AB', 'protection cd' => 'CD'}
                              })
  end

  describe 'empty protection_concerns' do
    it 'should return nil for unhcr_needs_codes' do
      child = Child.create!(protection_concerns: nil)
      expect(child.unhcr_needs_codes).to eq(nil)
    end
  end

  describe 'case with protection_concerns' do
    it 'should return valid unhcr_needs_codes' do
      child = Child.create! protection_concerns: ['protection ab','protection cd'],
                            unhcr_needs_codes: nil

      expect(child.unhcr_needs_codes).to eq(['AB','CD'])
    end

    it 'should map one to many' do
        @system_settings.unhcr_needs_codes_mapping.mapping =
                            {'protection ab' => 'AB', 'protection cd' => 'CD', 'protection ef' => 'AB'}
        @system_settings.save!

        child = Child.create!(protection_concerns: ['protection ab','protection ef'],
                              unhcr_needs_codes: nil)
        expect(child.unhcr_needs_codes).to eq(['AB'])
    end

    context 'should not return unhcr_needs_codes' do
      it 'when mapping is not defined' do
        @system_settings.unhcr_needs_codes_mapping.mapping = {}
        @system_settings.save!

        child = Child.create!(protection_concerns: ['protection ab','protection cd'],
                              unhcr_needs_codes: nil)
        expect(child.unhcr_needs_codes).to eq(nil)
      end

      it 'when autocalculate is set to false' do
        @system_settings.unhcr_needs_codes_mapping.autocalculate = false
        @system_settings.save!

        child = Child.create!(protection_concerns: ['protection ab','protection cd'],
                              unhcr_needs_codes: nil)
        expect(child.unhcr_needs_codes).to eq(nil)
      end
    end

    context 'should update unhcr_needs_codes' do
      it 'after protection_concerns change' do
        child = Child.create!(protection_concerns: ['protection ab'],
                                unhcr_needs_codes: ['AB','CD','EF'])
        expect(child.unhcr_needs_codes).to eq(['AB'])
      end

      it 'after settings change' do
        child = Child.create!(protection_concerns: ['protection ab'],
                                unhcr_needs_codes: ['AB','CD','EF'])

        @system_settings.unhcr_needs_codes_mapping.autocalculate = false
        @system_settings.save!

        child.attributes = {'name' => 'Johnny Bravo'}
        child.save!

        expect(child.unhcr_needs_codes).to eq(nil)
      end
    end
  end
end
