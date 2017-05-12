class JobOfferMailer < ApplicationMailer
  default from: 'youthline@boston.gov'

  def job_offer_email(user)
    @user = user
    @offer = user.applicant.offer
    @position = user.applicant.offer.position
    @accept_url  = 'http://dyee.mapc.org/offers/accept?email=' + user.email + '&token=' + user.authentication_token
    @decline_url = 'http://dyee.mapc.org/offers/decline?email=' + user.email + '&token=' + user.authentication_token
    mail(to: @user.email, subject: '2017 Successlink Lottery Job Offer - We’ve picked you for a summer job!')
  end
end
