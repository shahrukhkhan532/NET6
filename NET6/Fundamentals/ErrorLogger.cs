namespace NET6.Fundamentals;
public class ErrorLogger
{
    public string? LastError { get; set; }
    public void LogError(string error)
    {
        if (string.IsNullOrEmpty(error))
            throw new ArgumentNullException();
        LastError = error;
        // Write to some storage
    }
}
