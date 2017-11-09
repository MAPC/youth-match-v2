class JobOfferMailer < ApplicationMailer
  default from: 'youthline@boston.gov'

  def job_offer_email(user)
    @user = user
    @offer = user.applicant.offers.order(:created_at).last
    @position = @offer.position
    @accept_url  = root_url + 'offers?email=' + user.email + '&token=' + user.authentication_token + '&response=true'
    @decline_url = root_url + 'offers?email=' + user.email + '&token=' + user.authentication_token + '&response=false'
    mail(to: user.email, subject: '2017 Successlink Lottery Job Offer - We’ve picked you for a summer job!')
    @offer.update(accepted: 'offer_sent')
  end
end
