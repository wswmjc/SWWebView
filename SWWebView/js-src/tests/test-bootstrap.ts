export function describeIfApp(desc, target) {
    if (!(window as any).swwebviewSettings) {
        xdescribe(desc, target);
    } else {
        describe(desc, target);
    }
}
// This is generated by the rollup plugin
import "all-tests";