class ManualMatchesController < ApplicationController
  def new
    if params[:manual_match]
      @manual_match = ManualMatch.new(manual_match_params)
    else
      @manual_match = ManualMatch.new
    end
  end

  def create
    @manual_match = ManualMatch.new(manual_match_params.merge(company: current_company))
    if @manual_match.save
      if params[:bank_line_id]
        if (bank_line = bank_lines.find_by_id(params[:bank_line_id]))
          bank_line.update!(source: @manual_match)
        end
      end
      ManualProcessor.perform_async(@manual_match.id)
      redirect_to manual_matches_path
    else
      render :new
    end
  end

  def edit
    @manual_match = manual_matches.find(params[:id])
  end

  def update
    @manual_match = manual_matches.find(params[:id])
    if @manual_match.update(manual_match_params)
      ManualProcessor.perform_async(@manual_match.id)

      redirect_to manual_matches_path
    else
      render :new
    end
  end

  def index
    @manual_matches = manual_matches.order(date: :desc).page(params[:page])
  end

  private

  def manual_matches
    current_user.is_accountant? ? ManualMatch : current_company.manual_matches
  end

  def bank_lines
    current_user.is_accountant? ? BnakLine : current_company.bank_lines
  end

  def manual_match_params
    params.require(:manual_match).permit(
      :date,
      :payment_type,
      :payment_subtype,
      :amount,
    )
  end
end
