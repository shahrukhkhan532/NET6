namespace NET6.Fundamentals;
public class MathLibrary
{
    public IEnumerable<int> GetOddNumbers(int Limit)
    {
        for (int i = 0; i <= Limit; i++)
        {
            if(i % 2 != 0)
                yield return i;
        }
    }
}
