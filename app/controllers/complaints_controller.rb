class ComplaintsController < ApplicationController
  def make
    ActiveRecord::Base.transaction do
      create
      render json: { response: 'Complaint saved' }
    end
  rescue ActiveRecord::RecordInvalid
    render json: { response: "Something's not right, check yours keys / values" }
  end

  def search
    result = Operations::Search::Complaint.new.run(search_params)
    response = result.positive? ? "This place have #{result} complaints(s)" : 'This place dont have complaint(s)'
    render json: { response: response }
  end

  private

  def create
    company = Operations::Create::Company.new.run(complaint_params)
    locale = Operations::Create::Locale.new.run(complaint_params[:location], company[:id])
    Operations::Create::Complaint.new.run(complaint_params, company[:id], locale[:id])
  end

  def complaint_params
    params.require(:complaint).permit(:title, :company, :description, :location)
  end

  def search_params
    params.require(:search).permit(:company, :state, :city, :postcode)
  end
end
