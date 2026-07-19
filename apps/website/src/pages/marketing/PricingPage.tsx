import '../../styles/marketing/pricing.scss';

export function PricingPage() {
  return (
    <div id="PlansPg">
      <img src="/assets/pricing.jpg" alt="" />
      <div className="d1">
        <h1>Starter Pack</h1>
        <ul>
          <li>- Lorem ipsum dolor sit.</li>
          <li>- Lorem ipsum dolor sit amet.</li>
          <li>- Lorem, ipsum dolor.</li>
          <li>- Lorem ipsum dolor sit amet consectetur.</li>
        </ul>
        <h2 className="price">
          $ 100/ month <span>(1 month free)</span>
        </h2>
        <button type="button">Select Plan</button>
      </div>
      <div className="d2">
        <h1>Gold Pack</h1>
        <ul>
          <li>- Lorem ipsum dolor sit.</li>
          <li>- Lorem ipsum dolor sit amet.</li>
          <li>- Lorem, ipsum dolor.</li>
          <li>- Lorem ipsum dolor sit amet consectetur.</li>
        </ul>
        <h2 className="price">
          $ 200/ month <span>(1 month free)</span>
        </h2>
        <button type="button">Select Plan</button>
      </div>
      <div className="d3">
        <h1>Enterprise Pack</h1>
        <ul>
          <li>- Lorem ipsum dolor sit.</li>
          <li>- Lorem ipsum dolor sit amet.</li>
          <li>- Lorem, ipsum dolor.</li>
          <li>- Lorem ipsum dolor sit amet consectetur.</li>
        </ul>
        <h2 className="price">Contact us to dicuss Specifics</h2>
        <button type="button">Select Plan</button>
      </div>
    </div>
  );
}
