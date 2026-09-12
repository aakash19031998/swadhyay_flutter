/// Which KPI drill-down table (`DashboardKpiDetailEntity`) a screen wants —
/// the four overview metrics the Dashboard used to show as tappable cards.
/// Kept as its own enum (rather than folded away) since the drill-down
/// screen/route/mock data behind it are all still wired up, just not
/// currently reachable from the redesigned Dashboard UI.
enum DashboardKpiKind { firstReceive, qcPending, articleCount, empCount }
