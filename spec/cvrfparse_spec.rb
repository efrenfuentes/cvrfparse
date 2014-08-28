require 'rspec'
require 'cvrfparse'

describe 'Cvrfparse' do
  before(:each) do
    @parser = CVRFPARSE::CVRF_parser::new
    @schema_local = File.dirname(__FILE__) + '/schemadata/cvrf/1.1/cvrf.xsd'
    @document_valid = File.dirname(__FILE__) + '/sample-xml/CVRF-1.1-cisco-sa-20110525-rvs4000.xml'
    @document_invalid = File.dirname(__FILE__) + '/sample-xml/CVRF-1.1-cisco-sa-20110525-rvs4000-invalid.xml'
    @document_notwellformed = File.dirname(__FILE__) + '/sample-xml/CVRF-1.1-cisco-sa-20110525-rvs4000-notwellformed.xml'
  end

  describe 'valid' do
    it 'validate' do
      expect(@parser.validate(@document_valid)).to be_empty
    end

    it 'validate local' do
      expect(@parser.validate(@document_valid, @schema_local)).to be_empty
    end

    it 'parse' do

      puts @parser.parse(@document_valid, ['DocumentTile', 'DocumentType'])
    end
  end

  describe 'invalid' do
    it 'validate' do
      expect(@parser.validate(@document_invalid)).not_to be_empty
    end

    it 'validate local' do
      expect(@parser.validate(@document_invalid, @schema_local)).not_to be_empty
    end
  end

  describe 'not well formed' do
    it 'validate' do
      expect(@parser.validate(@document_notwellformed)).not_to be_empty
    end

    it 'validate local' do
      expect(@parser.validate(@document_notwellformed, @schema_local)).not_to be_empty
    end
  end
end