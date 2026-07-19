import '../../styles/marketing/coming-soon.scss';

type MarketingComingSoonPageProps = {
  title?: string;
};

export function MarketingComingSoonPage({
  title = 'Contact us to see it sooner',
}: MarketingComingSoonPageProps) {
  return (
    <div id="CommingSoon">
      <div className="cont">
        <img src="/assets/comming_soon.jpg" alt="" />
        <h1>{title}</h1>
      </div>
    </div>
  );
}
