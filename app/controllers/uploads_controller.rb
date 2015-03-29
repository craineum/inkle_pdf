class UploadsController < ApplicationController
  def show
  end

  def create
    send_data(generate_pdf, :filename => 'output.pdf', :type => 'application/pdf')
  end

  private
  def generate_pdf
    Prawn::Document.new do
      text 'The Robit Riddle'
    end.render
  end
end
