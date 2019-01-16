require 'rails_helper'

RSpec.describe Grant, type: :model do
  it { should respond_to(:name) }
  it { should respond_to(:short_name) }
end
