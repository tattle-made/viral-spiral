import { html, LitElement } from "lit";
import { ref, createRef } from "lit/directives/ref.js";
import * as d3 from "d3";

export class CalendarElem extends LitElement {
  containerRef = createRef();
  constructor() {
    super();
  }

  firstUpdated() {
    // var el = this.renderRoot.getElementById("#target");
    // var container = this.containerRef.value;
    // d3.select(container)
    //   .style("stroke-width", 4)
    //   .on("mouseover", function (d, i) {
    //     // console.log("hi");
    //     d3.select(container)
    //       .transition()
    //       .duration("50")
    //       .attr("opacity", "0.50");
    //   })
    //   .on("mouseout", function (d, i) {
    //     d3.select(container).transition().duration("50").attr("opacity", "1.0");
    //   });
    // this.containerRef.value.innerText = "ok";
  }

  render() {
    return html`
      <svg>
        <circle
          id="target"
          ${ref(this.containerRef)}
          style="fill: #69b3a2"
          stroke="black"
          cx="50"
          cy="50"
          r="40"
        ></circle>
      </svg>
    `;
  }
}

export var CalendarHook = {
  mounted() {
    console.log("mounted");
    var container = this.el;

    d3.select(container)
      .style("stroke-width", 4)
      .on("mouseover", function (d, i) {
        // console.log("hi");
        d3.select(container)
          .transition()
          .duration("50")
          .attr("opacity", "0.50");
      })
      .on("mouseout", function (d, i) {
        d3.select(container).transition().duration("50").attr("opacity", "1.0");
      });
    // set event listener on this element
    // this.el.addEventListener("abc")

    // this.handleEvent("sent_from_server", (data)=>{
    // })

    // this.pushEvent("send_event", {})
  },
};
