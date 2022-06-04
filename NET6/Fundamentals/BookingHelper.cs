namespace NET6.Fundamentals;

public static class BookingHelper
{
    public static string? OverlappingBookingExists(Booking booking)
    {
        if (booking.Status == "Cancelled")
            return string.Empty;
        var unitOfWork = new UnitOfWork();
        var bookings = unitOfWork.Query<Booking>()
            .Where(b => b.Id != booking.Id && b.Status != booking.Status);

        var overlappingBookings = bookings.FirstOrDefault(
            b => 
            booking.ArrivalDate >= b.ArrivalDate
            && booking.ArrivalDate < b.ArrivalDate
            || booking.DepartureDate > b.DepartureDate
            && booking.DepartureDate <= b.DepartureDate);
        return overlappingBookings == null ? string.Empty : overlappingBookings.Reference;
    }
}
public class UnitOfWork
{
    public IQueryable<Booking> Query<T>()
    {
        return new List<Booking>().AsQueryable();
    }
}
public class Booking
{
    public int Id { get; set; }
    public string? Status { get; set; }
    public DateTime ArrivalDate { get; set; }
    public DateTime DepartureDate { get; set; }
    public string? Reference { get; set; }
}
